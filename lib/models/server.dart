import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:shair/data/room.dart';
import 'package:shair/models/network_devices.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

abstract class Server {
  bool createRoom(Room room);
  bool deleteRoom(Room room);
  Future start();
  Future stop();
  Future shareFile(File file, OwnedRoom room);
  // Room lockRoom(Room room,String password);

}

class AppResponse extends shelf.Response {
  AppResponse.ok(
    Map<String, Object> body, {
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : super.ok(
          jsonEncode(body),
          headers: {
            if (headers != null) ...headers,
            'Content-Type': 'application/json'
          },
          context: context,
          encoding: encoding,
        );
}

class ShelfServer {
  final Set<Room> _rooms;

  shelf.Response _root(shelf.Request req) {
    return AppResponse.ok(
      {
        'status': 'ok',
        'isRunning': true,
        'app': 'shair',
      },
    );
  }

  shelf.Response _getRooms(shelf.Request req) {
    return AppResponse.ok({'rooms': _rooms.map((e) => e.toMap()).toList()});
  }

  late shelf_router.Router router;
  HttpServer? _server;

  ShelfServer(this._rooms) {
    router = shelf_router.Router();
    router.get('/', _root);
    router.get('/rooms', _getRooms);
  }

  Future<void> start() async {
    if (_server != null) return;
    _server = await io.serve(router, '0.0.0.0', kPort);
    return;
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
    return;
  }
}

class RestServer extends Server with ChangeNotifier {
  final Set<Room> _rooms = {};

  late ShelfServer server = ShelfServer(_rooms);

  @override
  Future start() => server.start();
  @override
  Future stop() => server.stop();

  @override
  bool createRoom(Room room) {
    return _rooms.add(room);
  }

  @override
  bool deleteRoom(Room room) {
    return _rooms.remove(room);
  }

  @override
  Future shareFile(File file, OwnedRoom room) async {
    if (!await file.exists()) return;
    final stats = await file.stat();
    final downloadableFile = DownloadableFile.fromBaseUrl(
        baseUrl: 'rooms/${room.id}', size: stats.size);
    room.addFile(downloadableFile);
  }
}
