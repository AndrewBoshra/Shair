import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shair/data/config.dart';

import 'package:shair/data/room.dart';
import 'package:shair/services/network_devices.dart';

class RestClient {
  final Api _api = Api();

  @override
  Future<List<Room>?> getRooms(Device device) async {
    final res = await _api.get(device.url);
    if (res.hasError) return [];
    if (res.parsedResponse?['app'] != 'shair') return null;

    final roomsRaw = res.parsedResponse!['rooms'] as List;

    final rooms = <Room>[];
    for (final raw in roomsRaw) {
      final room = Room.fromMap(raw, owner: device);

      rooms.add(room);
    }
    return rooms;
  }

  @override
  Future<JoinedRoom?> askToJoin(
    Room room,
    Config config,
    String code,
    String ip,
  ) async {
    final res = await _api.post('${room.owner!.url}/room/${room.id}/join',
        code: code, personDetails: config.personDetails, body: {'ip': ip});

    if (res.hasError) return null;

    return JoinedRoom.fromMap(res.parsedResponse!,
        idInRoom: res.parsedResponse!['code'] as String?, owner: room.owner);
  }

  @override
  Future<WebSocket?> join(JoinedRoom room) async {
    if (room.owner == null) {
      return room.webSocket;
    }
    try {
      final ws = await WebSocket.connect(
          '${room.owner!.socketUrl}/room/${room.id}/channel',
          headers: {'code': room.idInRoom});
      room.webSocket = ws;
      return ws;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  Future<JoinedRoom> getRoomDetails(JoinedRoom room) async {
    //owned by this device
    if (room.owner == null) return room;

    final res = await _api.get(
      '${room.owner!.url}/room/${room.id}',
      code: room.idInRoom,
    );
    if (res.hasError || res.response!.statusCode != 200) {
      throw Exception('couldn\'t access room $room');
    }
    return JoinedRoom.fromMap(res.parsedResponse!);
  }
}

class ApiResponse {
  bool get hasError =>
      parsedResponse == null || response == null || response!.statusCode >= 400;
  bool get hasData => !hasError;
  final Map<String, Object?>? parsedResponse;
  final http.Response? response;
  final Object? error;

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
    } catch (e) {
      return ApiResponse(error: e);
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
