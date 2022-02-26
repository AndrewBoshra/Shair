import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:shair/actions/actions.dart';
import 'package:shair/app_globals.dart';
import 'package:shair/data/config.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/services/socket.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:mime/mime.dart';

import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'package:shair/data/room.dart';

class DownloadRange {
  final int start;
  final int end;
  DownloadRange._(this.start, this.end);

  int get size => end - start;
  factory DownloadRange.fromHeaders(
      Map<String, String?> headers, FileStat stat) {
    final size = stat.size;
    final rawRange = headers["range"];
    if (rawRange == null) return DownloadRange._(0, size);

    final positions = rawRange
        .replaceAll("bytes=", "")
        .split("-")
        .where((s) => s.isNotEmpty)
        .toList();
    if (positions.isEmpty) return DownloadRange._(0, size);

    final startStr = positions.first;
    final start = int.parse(startStr);

    var end = size;
    if (positions.length > 1) {
      end = int.parse(positions[1]);
    }

    return DownloadRange._(start, end);
  }
}

class ProtectedRoutes {
  final AppModel _appModel;
  late shelf_router.Router _router;
  Set<JoinedRoom> get _accessibleRooms => _appModel.accessibleRooms;

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

      final valid = _accessibleRooms.any((room) => room.id == roomId);
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
      final room = _accessibleRooms.firstWhere((room) => room.id == roomId);

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
    final room = _getAccessibleRoomWithId(id);
    if (room is! OwnedRoom) {
      return AppResponse.notFound({'message': 'room is not mine'});
    }
    final body = await req.body;
    final personDetails = PersonDetails.fromMap(body);

    final joinRequest = JoinRequest(
      personDetails: personDetails,
      code: req.headers['code'] as String,
      room: room,
    );
    _appModel.actionsSink.add(joinRequest);
    final joinResponse = await _appModel.responseStream.firstWhere(
      (res) => res.id == joinRequest.id,
    );
    if (joinResponse is! JoinResponse || !joinResponse.isAccepted) {
      return AppResponse.forbidden({});
    }

    return AppResponse.ok({...room.toMap(), 'code': joinResponse.code});
  }

  Future<shelf.Response> _getFile(shelf.Request req) async {
    final fileId = req.params['file-id']!;
    final roomId = req.params['id']!;
    final room = _getAccessibleRoomWithId(roomId)!;

    final myFiles = room.myFiles;
    final files = myFiles.where((sharedFile) => sharedFile.file.id == fileId);
    if (files.isEmpty) return AppResponse.notFound({});

    final sharedFile = files.first;
    final file = File(sharedFile.file.path ?? '');
    final mime = lookupMimeType(file.path);
    if (mime == null || !await file.exists()) {
      return AppResponse.notFound({});
    }
    final stat = await file.stat();
    final range = DownloadRange.fromHeaders(req.headers, stat);

    return shelf.Response(
      206,
      body: file.openRead(range.start, range.end),
      encoding: const Utf8Codec(),
      headers: {
        'content-type': mime,
        'content-disposition':
            'attachment; filename=${utf8.encode(sharedFile.file.name)}',
        'content-length': range.size.toString(),
        'content-range': 'bytes ${range.start} - ${range.end} / ${stat.size}',
        "accept-ranges": "bytes",
      },
    );
  }

  //////////////////////////
  //       Helpers        //
  //////////////////////////

  JoinedRoom? _getAccessibleRoomWithId(String roomId) {
    final matchingRooms = _accessibleRooms.where((room) => room.id == roomId);
    if (matchingRooms.isEmpty) return null;
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
  Set<OwnedRoom> get _rooms => _appModel.myRooms;
  late shelf_router.Router router;
  HttpServer? _server;
  late final ProtectedRoutes _protectedRoutes;
  SocketService get socketService => _protectedRoutes.socketService;

  static String get userImagePath => '/user-image';

  AppResponse _getRooms(shelf.Request req) {
    return AppResponse.ok(
      {
        'status': 'ok',
        'isRunning': true,
        'app': 'shair',
        'rooms': _rooms.map((e) => e.toMap(false, false)).toList()
      },
    );
  }

  shelf.Response _getImage(shelf.Request req) {
    final imagePath = AppGlobals.config.character?.path;
    if (imagePath == null) {
      return AppResponse.notFound({'message': "user has no image"});
    }
    final mime = lookupMimeType(imagePath);
    return shelf.Response(
      200,
      body: File(imagePath).openRead(),
      headers: {
        'content-type': mime ?? 'image/',
      },
    );
  }

  static String roomImageUrl(Device owner, String id) =>
      owner.url + _roomImageUrl.replaceAll('<id>', id);
  static const String _roomImageUrl = '/room/<id>/image';

  shelf.Response _getRoomImage(shelf.Request req, String roomId) {
    final room = _appModel.ownedRoomWithId(roomId);
    if (room == null || room.roomImage?.path == null) {
      return AppResponse.notFound({});
    }
    final imagePath = room.roomImage!.path!;
    final mime = lookupMimeType(imagePath);
    return shelf.Response(
      200,
      body: File(imagePath).openRead(),
      headers: {
        'content-type': mime ?? 'image/',
      },
    );
  }

  RestServer(this._appModel) {
    router = shelf_router.Router();
    _protectedRoutes = ProtectedRoutes(_appModel);
    router
      ..get('/', _getRooms)
      ..get(userImagePath, _getImage)
      ..get(_roomImageUrl, _getRoomImage)
      ..mount('/room', _protectedRoutes.router);
  }

  Future<void> start() async {
    if (_server != null) return;
    _server = await io.serve(
        shelf.logRequests().addHandler(router), '0.0.0.0', kPort);
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
