import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:shair/data/room.dart';
import 'package:shair/data/shared_file.dart';
import 'package:shair/models/client.dart';
import 'package:shair/models/network_devices.dart';
import 'package:shair/models/server.dart';

const _kPollDuration = Duration(milliseconds: 1000);

abstract class AppModel extends ChangeNotifier {
  UnmodifiableSetView<Room> get rooms;
  Room create(Room room);
  Future<Room> join(Room room);
  Future<void> leave(Room room);
  void sendFile(File file, Room room);
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
  UnmodifiableSetView<Room> get rooms => UnmodifiableSetView(_rooms);

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
  void sendFile(File file, Room room) {
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
  UnmodifiableSetView<Room> get rooms => UnmodifiableSetView({
        Room(id: 'aaadjiksa', isLocked: false, name: 'Room1'),
        Room(id: 'aaadsasda', isLocked: true, name: 'Room2'),
        Room(id: 'aasaddsaa', isLocked: true, name: 'Room3'),
        Room(id: 'dsadsadas', isLocked: false, name: 'Room4'),
      });

  @override
  void sendFile(File file, Room room) {
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
