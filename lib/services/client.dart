import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'package:shair/data/room.dart';
import 'package:shair/services/network_devices.dart';

class JoinResponse {
  final bool isAccepted;
  String? idInRoom;
  String? roomId;
  JoinResponse({
    required this.isAccepted,
    this.roomId,
    this.idInRoom,
  });

  Map<String, Object> toMap() {
    return {
      'isAccepted': isAccepted,
      'idInRoom': idInRoom ?? '',
      'roomId': roomId ?? ''
    };
  }
}

abstract class Client {
  Future<bool> isActive(Device device);
  Future<List<Room>> getRooms(Device device);
  Future<bool> askHostToShareFile(PlatformFile file, Room room);
  Future<JoinResponse> askToJoin(Room room);

  /// Must be joined to that room
  Future<Room> getRoomDetails(Room room);
  Future<void> notifyParticipantsAboutFile(PlatformFile file, Room room);
}

class RestClient implements Client {
  final Api _api = Api();
  @override
  Future<List<Room>> getRooms(Device device) async {
    final res = await _api.get(device.url + '/rooms');
    if (res.hasError) return [];
    final roomsRaw = res.parsedResponse!['rooms'] as List;

    final rooms = <Room>[];
    for (final raw in roomsRaw) {
      rooms.add(Room.fromMap(raw));
    }
    return rooms;
  }

  @override
  Future<bool> isActive(Device device) async {
    try {
      final response = await _api.get(device.url);
      return response.parsedResponse?['app'] == 'shair';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> askHostToShareFile(PlatformFile file, Room room) {
    throw UnimplementedError();
  }

  @override
  Future<void> notifyParticipantsAboutFile(PlatformFile file, Room room) async {
    throw UnimplementedError();
  }

  @override
  Future<JoinResponse> askToJoin(Room room) async {
    throw UnimplementedError();
  }

  @override
  Future<Room> getRoomDetails(Room room) async {
    //owned by this device
    if (room.owner == null) return room;

    final res = await _api.get('${room.owner!.url}/rooms/${room.id}',
        headers: {'userId': room.idInRoom!});
    if (res.hasError || res.response!.statusCode != 200) {
      throw Exception('couldn\'t access room $room');
    }
    return Room.fromMap(res.parsedResponse!);
  }
}

class ApiResponse {
  bool get hasError => parsedResponse == null;
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

      return ApiResponse(parsedResponse: data);
    } catch (e) {
      return ApiResponse(error: e);
    }
  }

  Future<ApiResponse> get(String url, {Map<String, String>? headers}) async {
    return _handleRequest(() => http.get(Uri.parse(url), headers: headers));
  }

  Future<ApiResponse> post(String url,
      {Map<String, String>? headers, Map<String, String>? body}) async {
    return _handleRequest(
      () => http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ),
    );
  }
}
