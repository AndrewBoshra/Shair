import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:shair/data/room.dart';
import 'package:shair/data/shared_file.dart';
import 'package:shair/models/client.dart';
import 'package:shair/models/network_devices.dart';
import 'package:shair/models/server.dart';

const _kPollDuration = Duration(milliseconds: 1000);

abstract class AppModel extends ChangeNotifier {
  UnmodifiableSetView<Room> get rooms;
  Future<Room> create(String name, String? image, bool isLocked);
  Future<Room> join(Room room);
  Future<void> leave(Room room);
  Future<void> shareFile(PlatformFile file, Room room);
  Future<void> download(SharedFile file);
  void pollRooms();
  void stopPollingRooms();
  Room? getRoomWithId(String id);
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
  Room? getRoomWithId(String id) {
    final room = _rooms.firstWhere((room) => room.id == id, orElse: Room.empty);
    return room.isValid ? room : null;
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

  Future<void> _serveFile(PlatformFile file, Room room) async {
    await server.shareFile(File(file.path!), room);
  }

  @override
  Future<void> shareFile(PlatformFile file, Room room) async {
    print('share : ${file.path} ${file.size}');
    if (room.device == await networkDevices.currentDevice) {
      await _serveFile(file, room);
      await client.notifyParticipantsAboutFile(file, room);
    } else {
      if (await client.askHostToShareFile(file, room)) {
        await _serveFile(file, room);
      }
    }
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

  @override
  Future<Room> create(String name, String? image, bool isLocked) async {
    final room = Room(
      await networkDevices.currentDevice,
      name: name,
      isLocked: isLocked,
      image: image,
    );
    if (server.createRoom(room)) {
      _rooms.add(room);
    }
    return room;
  }
}
