import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:shair/data/room.dart';
import 'package:shair/data/shared_file.dart';

abstract class AppModel extends ChangeNotifier {
  Future<List<Room>> get rooms;
  Room create(Room room);
  Future<Room> join(Room room);
  Future<void> leave(Room room);
  void sendFile(File file);
  Future<void> download(SharedFile file);
}

class AppModelRest extends AppModel {
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
  // TODO: implement rooms
  Future<List<Room>> get rooms => throw UnimplementedError();

  @override
  void sendFile(File file) {
    // TODO: implement sendFile
    throw UnimplementedError();
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
  Future<List<Room>> get rooms async => [
        Room(),
        Room(),
        Room(),
        Room(),
        Room(),
        Room(),
      ];

  @override
  void sendFile(File file) {
    print('send ${file.path}');
  }
}
