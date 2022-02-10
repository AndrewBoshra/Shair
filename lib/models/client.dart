import 'dart:convert';

import 'package:shair/data/room.dart';
import 'package:shair/models/network_devices.dart';
import 'package:http/http.dart' as http;

abstract class Client {
  Future<bool> isActive(Device device);
  Future<List<Room>> getRooms(Device device);
}

class RestClient implements Client {
  @override
  Future<List<Room>> getRooms(Device device) {
    // TODO: implement getRooms
    throw UnimplementedError();
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
