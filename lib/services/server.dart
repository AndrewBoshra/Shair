import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shair/actions/actions.dart';
import 'package:shair/data/config.dart';
import 'package:shair/models/app_model.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'package:shair/data/room.dart';

abstract class Server {
  Future start();
  Future stop();
}

class ProtectedRoutes {
  final AppModel _appModel;
  late shelf_router.Router _router;

  Set<JoinedRoom> get _rooms => _appModel.myRooms;

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
      final room = _rooms.firstWhere((room) => room.id == roomId,
          orElse: JoinedRoom.empty);
      if (!room.isValid) {
        return AppResponse.notFound({});
      }
      return innerHandler(request);
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

    return AppResponse.ok(room.toMap());
  }

  //////////////////////////
  //       Helpers        //
  //////////////////////////

  JoinedRoom? _getRoomWithId(String roomId) {
    final matchingRooms = _rooms.where((room) => room.id == roomId);
    if (matchingRooms.isEmpty) null;
    return matchingRooms.first;
  }

  shelf.Handler get router =>
      const shelf.Pipeline().addMiddleware(_auth).addHandler(_router);

  ProtectedRoutes(this._appModel) {
    _router = shelf_router.Router();
    _router
      ..post(
        '/<id>/join',
        const shelf.Pipeline()
            .addMiddleware(_validateRoom)
            .addHandler(_joinRoom),
      );
  }
}

class RestServer extends Server {
  final AppModel _appModel;
  Set<JoinedRoom> get _rooms => _appModel.myRooms;
  late shelf_router.Router router;
  HttpServer? _server;

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
    router
      ..get('/', _getRooms)
      ..mount('/room', ProtectedRoutes(_appModel).router);
  }

  @override
  Future<void> start() async {
    if (_server != null) return;
    // _server = await io.serve(router, '0.0.0.0', kPort);
    //TODO change this port to kPort this is only for dev
    _server =
        await io.serve(shelf.logRequests().addHandler(router), '0.0.0.0', 3000);
    return;
  }

  @override
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

extension JsonRequest on shelf.Request {
  Future<Map<String, dynamic>> get body async =>
      jsonDecode(await readAsString());
}
