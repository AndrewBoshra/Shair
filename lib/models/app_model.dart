import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';
import 'package:shair/data/room.dart';
import 'package:shair/data/shared_file.dart';
import 'package:shair/models/client.dart';
import 'package:shair/models/network_devices.dart';
import 'package:shair/models/server.dart';

const _kPollDuration = Duration(milliseconds: 500);

abstract class AppModel extends ChangeNotifier {
  UnmodifiableListView<Room> get rooms;
  Room create(Room room);
  Future<Room> join(Room room);
  Future<void> leave(Room room);
  void sendFile(File file);
  Future<void> download(SharedFile file);
  void pollRooms();
  void stopPollingRooms();
}

class AppModelRest extends AppModel {
  final Client client;
  final Server server;
  bool _ispollingRooms = false;
  NetworkDevices networkDevices;
  Set<Room> _rooms = {};

  AppModelRest(this.client, this.server, this.networkDevices);

  Future<List<Room>> _fetchRooms() async {
    _rooms = {};
    final devices = await networkDevices.devices;
    for (final device in devices) {
      if (await client.isActive(device)) {
        final deviceRooms = await client.getRooms(device);
        _rooms.addAll(deviceRooms);
      }
    }
    return _rooms.toList();
  }

  @override
  UnmodifiableListView<Room> get rooms => UnmodifiableListView(_rooms);

  @override
  Room create(Room room) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> download(SharedFile file) {
    // TODO: implement download
    throw UnimplementedError();
  }

  @override
  Future<Room> join(Room room) {
    // TODO: implement join
    throw UnimplementedError();
  }

  @override
  Future<void> leave(Room room) {
    // TODO: implement leave
    throw UnimplementedError();
  }

  @override
  void sendFile(File file) {
    // TODO: implement sendFile
    throw UnimplementedError();
  }

  @override
  void pollRooms() {
    if (_ispollingRooms) return;
    _ispollingRooms = true;
    Future.doWhile(() async {
      await _fetchRooms();
      debugPrint('finished _fetchRooms');
      notifyListeners();
      await Future.delayed(_kPollDuration);
      return _ispollingRooms;
    });
  }

  @override
  void stopPollingRooms() {
    _ispollingRooms = false;
    debugPrint('stopped polling');
  }
}

class AppModelMock extends AppModel {
  @override
  Room create(Room room) {
    print('Create Room');
    return room;
  }

  @override
  Future<void> download(SharedFile file) {
    print('Download $file');
    return Future.delayed(Duration(seconds: 6));
  }

  @override
  Future<Room> join(Room room) async {
    print('join $room');
    await Future.delayed(Duration(seconds: 1));
    return room;
  }

  @override
  Future<void> leave(Room room) async {
    print('leave $room');
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  UnmodifiableListView<Room> get rooms => UnmodifiableListView([
        Room(),
        Room(),
        Room(),
        Room(),
        Room(),
        Room(),
      ]);

  @override
  void sendFile(File file) {
    print('send ${file.path}');
  }

  @override
  void pollRooms() {
    // TODO: implement pollRooms
  }

  @override
  void stopPollingRooms() {
    // TODO: implement stopPollingRooms
  }
}
