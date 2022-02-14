import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'package:shair/data/room.dart';

abstract class Server {
  Future start();
  Future stop();

  // Room lockRoom(Room room,String password);

}

class RestServer extends Server {
  final AppModel _appModel;
  Set<Room> get _rooms => _appModel.myRooms;

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

  shelf.Response _getRoom(shelf.Request req, String roomId) {
    final matchingRooms = _rooms.where((room) => room.id == roomId);
    if (matchingRooms.isEmpty) {
      return AppResponse.notFound(
          {'status': 'error', 'message': 'room not found'});
    }
    throw UnimplementedError();
  }

  _auth({required Function innerHandler}) {
    return ((request, [arg]) {
      final userId = request.headers['userId'];
      if (userId == null) {
        return AppResponse.forbidden(
            {'status': 'error', 'message': 'id is required'});
      }
      return innerHandler(request, arg);
    });
  }

  _validateRoom({required Function innerHandler}) {
    return ((request, roomId) {
      final room =
          _rooms.firstWhere((room) => room.id == roomId, orElse: Room.empty);
      if (!room.isValid) {
        return AppResponse.notFound({});
      }
      return innerHandler(request, roomId);
    });
  }

  late shelf_router.Router router;
  HttpServer? _server;

  RestServer(this._appModel) {
    router = shelf_router.Router();
    router.get('/', _root);
    router.get('/rooms', _getRooms);
    // router.get('/rooms/<id>', _auth(innerHandler: _getRoom));
  }

  Future<void> start() async {
    if (_server != null) return;
    // _server = await io.serve(router, '0.0.0.0', kPort);
    //TODO change this port to kPort this is only for dev
    _server = await io.serve(router, '0.0.0.0', 3000);
    return;
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
    return;
  }
}

class AppResponse extends shelf.Response {
  AppResponse.ok(
    Map<String, Object> body, {
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : super.ok(
          jsonEncode({...body, 'status': 'succes'}),
          headers: {
            if (headers != null) ...headers,
            'Content-Type': 'application/json'
          },
          context: context,
          encoding: encoding,
        );
  AppResponse.notFound(
    Map<String, Object> body, {
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : super.notFound(
          jsonEncode({...body, 'status': 'error'}),
          headers: {
            if (headers != null) ...headers,
            'Content-Type': 'application/json'
          },
          context: context,
          encoding: encoding,
        );

  AppResponse.forbidden(
    Map<String, Object> body, {
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : super.forbidden(
          jsonEncode({...body, 'status': 'error'}),
          headers: {
            if (headers != null) ...headers,
            'Content-Type': 'application/json'
          },
          context: context,
          encoding: encoding,
        );
}
