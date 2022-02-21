import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:shair/actions/actions.dart';
import 'package:shair/data/config.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/services/socket.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:mime/mime.dart';

import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'package:shair/data/room.dart';

class ProtectedRoutes {
  final AppModel _appModel;
  late shelf_router.Router _router;

  Set<OwnedRoom> get _rooms => _appModel.myRooms;

  // MiddleWares
  shelf.Handler _auth(innerHandler) {
    return (request) {
      final userId = request.headers['code'];
      if (userId == null) {
        return AppResponse.forbidden({'message': 'user code is required'});
      }
      return innerHandler(request);
    };
  }

  shelf.Handler _validateRoom(innerHandler) {
    return (request) {
      final roomId = request.params['id'];

      final valid = _rooms.any((room) => room.id == roomId);
      if (!valid) {
        return AppResponse.notFound({});
      }
      return innerHandler(request);
    };
  }

  shelf.Handler _joinedRoom(innerHandler) {
    return (request) {
      final roomId = request.params['id']!;
      final userCode = request.headers['code']!;
      final room = _rooms.firstWhere((room) => room.id == roomId);

      if (room.isInRoom(userCode)) {
        return innerHandler(request);
      } else {
        debugPrint('request code is not in room');
        return AppResponse.forbidden({});
      }
    };
  }

  //////////////////////////
  //       Handlers       //
  //////////////////////////

  Future<AppResponse> _joinRoom(shelf.Request req) async {
    final id = req.params['id']!;
    final room = _getRoomWithId(id)!;
    final body = await req.body;
    final personDetails = PersonDetails.fromMap(body);

    final joinRequest = JoinRequest(
      personDetails: personDetails,
      code: req.headers['code'] as String,
      room: room,
    );
    _appModel.actionsSink.add(joinRequest);

    final joinResponse = await _appModel.responseStream
        .firstWhere((res) => res.id == joinRequest.id);
    if (joinResponse is! JoinResponse || !joinResponse.isAccepted) {
      return AppResponse.forbidden({});
    }

    return AppResponse.ok({...room.toMap(), 'code': joinResponse.code});
  }

  Future<shelf.Response> _getFile(shelf.Request req) async {
    final fileId = req.params['file-id']!;
    final roomId = req.params['id']!;
    final room = _getRoomWithId(roomId)!;

    final myFiles = room.myFiles;
    final files = myFiles.where((file) => file.id == fileId);
    if (files.isEmpty) return AppResponse.notFound({});

    final downloadableFile = files.first;
    final file = File(downloadableFile.path ?? '');
    final mime = lookupMimeType(file.path);
    if (mime == null || !await file.exists()) {
      return AppResponse.notFound({});
    }
    return shelf.Response.ok(file.openRead(), headers: {
      'Content-Type': mime,
      'Content-Disposition': 'attachment filename=${downloadableFile.name}'
    });
  }

  //////////////////////////
  //       Helpers        //
  //////////////////////////

  OwnedRoom? _getRoomWithId(String roomId) {
    final matchingRooms = _rooms.where((room) => room.id == roomId);
    if (matchingRooms.isEmpty) null;
    return matchingRooms.first;
  }

  shelf.Handler get router =>
      const shelf.Pipeline().addMiddleware(_auth).addHandler(_router);
  late final SocketService socketService;

  ProtectedRoutes(this._appModel) {
    _router = shelf_router.Router();
    final validRoomPipe = const shelf.Pipeline().addMiddleware(_validateRoom);
    final joinedRoomPipe = validRoomPipe.addMiddleware(_joinedRoom);
    _router.post(
      '/<id>/join',
      validRoomPipe.addHandler(_joinRoom),
    );
    socketService = SocketService();
    _router.all(
      '/<id>/channel',
      joinedRoomPipe.addHandler(socketService.handler),
    );
    _router.get('/<id>/files/<file-id>', joinedRoomPipe.addHandler(_getFile));
  }
}

class RestServer {
  final AppModel _appModel;
  Set<JoinedRoom> get _rooms => _appModel.myRooms;
  late shelf_router.Router router;
  HttpServer? _server;
  late final ProtectedRoutes _protectedRoutes;

  SocketService get socketService => _protectedRoutes.socketService;

  AppResponse _getRooms(shelf.Request req) {
    return AppResponse.ok(
      {
        'status': 'ok',
        'isRunning': true,
        'app': 'shair',
        'rooms': _rooms.map((e) => e.toMap()).toList()
      },
    );
  }

  RestServer(this._appModel) {
    router = shelf_router.Router();
    _protectedRoutes = ProtectedRoutes(_appModel);
    router
      ..get('/', _getRooms)
      ..mount('/room', _protectedRoutes.router);
  }

  Future<void> start() async {
    if (_server != null) return;
    _server = await io.serve(
        shelf.logRequests().addHandler(router), '0.0.0.0', kPort);
    //TODO change this port to kPort this is only for dev
    // _server =
    // await io.serve(shelf.logRequests().addHandler(router), '0.0.0.0', 3000);
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
    Map<String, Object?> body, {
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : super.ok(
          jsonEncode({...body, 'status': 'success'}),
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

extension JsonRequest on shelf.Request {
  Future<Map<String, dynamic>> get body async =>
      jsonDecode(await readAsString());
}
