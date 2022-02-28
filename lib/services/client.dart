import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shair/app_globals.dart';
import 'package:shair/core/failures.dart';
import 'package:shair/data/config.dart';

import 'package:shair/data/room.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/styled_components/avatar.dart';

class RestClient {
  final Api _api = Api();

  Future<Either<Failure, List<Room>>> getRooms(Device device) async {
    final res = await _api.get(device.url);
    if (res.hasError || res.parsedResponse?['app'] != 'shair') {
      return left(Failure('couldn\'t fetch rooms', res.error));
    }

    final roomsRaw = res.parsedResponse!['rooms'] as List;

    final rooms = <Room>[];
    for (final raw in roomsRaw) {
      final room = Room.fromMap(raw, owner: device);
      rooms.add(room);
    }
    return right(rooms);
  }

  Future<Either<Failure, JoinedRoom>> askToJoin(
    Room room,
    Config config,
    String? code,
    String ip,
  ) async {
    final currentDeviceEither = await WifiNetworkDevices.currentDevice;
    return currentDeviceEither.fold(left, (currentDevice) async {
      final res = await _api.post(
        '${room.owner.url}/room/${room.id}/join',
        code: code ?? '---',
        personDetails: config.personDetails
            .copyWith(character: CharacterImage(url: currentDevice.imageUrl)),
        body: {'ip': ip},
      );

      //TODO
      if (res.hasError) return left(Failure('message', res.error));
      final currentUser = RoomUser.formConfig(
        config,
        code: res.parsedResponse!['code'] as String?,
      );
      return right(JoinedRoom.fromMap(
        res.parsedResponse!,
        currentUser,
        owner: room.owner,
      ));
    });
  }

  Future<Either<Failure, WebSocket>> join(JoinedRoom room) async {
    try {
      final ws = await WebSocket.connect(
          '${room.owner.socketUrl}/room/${room.id}/channel',
          headers: {'code': room.idInRoom});
      room.webSocket = ws;
      return right(ws);
    } on WebSocketException catch (e) {
      return left(Failure(e.message, e));
    }
  }
}

class ApiResponse {
  bool get hasError =>
      parsedResponse == null || response == null || response!.statusCode >= 400;
  bool get hasData => !hasError;
  final Map<String, Object?>? parsedResponse;
  final http.Response? response;
  final Failure? error;

  ApiResponse({this.parsedResponse, this.error, this.response})
      : assert(parsedResponse == null || error == null);
}

class Api {
  Future<ApiResponse> _handleRequest(
      Future<http.Response> Function() fn) async {
    try {
      final response = await fn();
      final data = jsonDecode(response.body);

      return ApiResponse(parsedResponse: data, response: response);
    } on SocketException catch (e) {
      return ApiResponse(error: Failure(e.message, e));
    }
  }

  Future<ApiResponse> get(
    String url, {
    Map<String, String>? headers,
    String? code,
  }) async {
    return _handleRequest(
      () => http.get(
        Uri.parse(url),
        headers: {
          if (headers != null) ...headers,
          if (code != null) 'code': code,
        },
      ),
    );
  }

  Future<ApiResponse> getFile(
    String url, {
    Map<String, String>? headers,
    String? code,
  }) async {
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {
          if (headers != null) ...headers,
          if (code != null) 'code': code,
        },
      );
      if (res.statusCode >= 400) {
        throw Failure('couldn\'t download file response : $res');
      }

      return ApiResponse(parsedResponse: {}, response: res);
    } on SocketException catch (e) {
      return ApiResponse(
        error: Failure(e.message, e),
      );
    }
  }

  Future<ApiResponse> post(String url,
      {Map<String, String>? headers,
      Map<String, String>? body,
      String? code,
      PersonDetails? personDetails}) async {
    final _body = {
      if (body != null) ...body,
      if (personDetails != null) ...personDetails.toMap(),
    };
    return _handleRequest(
      () => http.post(
        Uri.parse(url),
        headers: {
          if (headers != null) ...headers,
          if (code != null) 'code': code,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(_body),
      ),
    );
  }
}
