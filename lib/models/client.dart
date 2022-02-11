import 'dart:convert';

import 'package:shair/data/room.dart';
import 'package:shair/models/network_devices.dart';
import 'package:http/http.dart' as http;

abstract class Client {
  Future<bool> isActive(Device device);
  Future<List<Room>> getRooms(Device device);
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
      final response = await http.get(Uri.parse(device.url));
      final body = jsonDecode(response.body);
      return body['app'] == 'shair';
    } catch (e) {
      return false;
    }
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
