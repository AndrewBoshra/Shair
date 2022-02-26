import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shair/app_globals.dart';
import 'package:shair/data/config.dart';

import 'package:shair/data/room.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/styled_components/avatar.dart';

class RestClient {
  final Api _api = Api();

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

  Future<JoinedRoom?> askToJoin(
    Room room,
    Config config,
    String? code,
    String ip,
  ) async {
    final currentDevice = await AppGlobals.wifiDevices.currentDevice;

    final res = await _api.post(
      '${room.owner.url}/room/${room.id}/join',
      code: code,
      personDetails: config.personDetails
          .copyWith(character: CharacterImage(url: currentDevice.imageUrl)),
      body: {'ip': ip},
    );

    if (res.hasError) return null;
    final currentUser = RoomUser.formConfig(
      config,
      code: res.parsedResponse!['code'] as String?,
    );
    return JoinedRoom.fromMap(
      res.parsedResponse!,
      currentUser,
      owner: room.owner,
    );
  }

  Future<WebSocket?> join(JoinedRoom room) async {
    try {
      final ws = await WebSocket.connect(
          '${room.owner.socketUrl}/room/${room.id}/channel',
          headers: {'code': room.idInRoom});
      room.webSocket = ws;
      return ws;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Future<File?> downloadFileFormRoom(
  //     DownloadableFile downloadableFile, JoinedRoom room) async {
  //   final res = await _api.getFile(downloadableFile.url, code: room.idInRoom);
  //   final dataPath = await path_provider.getApplicationDocumentsDirectory();
  //   final filePath = path.join(dataPath.path, 'Shair', downloadableFile.name);
  //   if (res.hasError) return null;

  //   final savedFile = File(filePath);
  //   final openedFile = await savedFile.create();
  //   await openedFile.writeAsBytes(res.response!.bodyBytes);
  //   return openedFile;
  // }
  // Future<JoinedRoom> getRoomDetails(JoinedRoom room) async {
  //   //owned by this device
  //   if (room.owner == null) return room;

  //   final res = await _api.get(
  //     '${room.owner!.url}/room/${room.id}',
  //     code: room.idInRoom,
  //   );
  //   if (res.hasError || res.response!.statusCode != 200) {
  //     throw Exception('couldn\'t access room $room');
  //   }
  //   return JoinedRoom.fromMap(res.parsedResponse!);
  // }
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
        throw Exception('couldn\'t download file');
      }

      return ApiResponse(parsedResponse: {}, response: res);
    } catch (e) {
      return ApiResponse(
        error: e,
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
