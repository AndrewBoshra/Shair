import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';
import 'package:shair/models/app_model.dart';

abstract class SocketMessage extends ICommand {
  final WebSocketChannel webSocket;
  SocketMessage(this.webSocket);
}

class InitMessage extends SocketMessage {
  final String name;
  final String imageUrl;
  final String code;
  final Room room;
  InitMessage({
    required this.name,
    required this.imageUrl,
    required this.code,
    required this.room,
    required WebSocketChannel webSocket,
  }) : super(webSocket);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'code': code,
      'roomId': room.id,
    };
  }

  factory InitMessage.fromMap(
      Map<String, dynamic> map, WebSocketChannel webSocket) {
    final roomId = map['roomId'];
    final room = ICommand.sAppModel.accessibleRoomWithId(roomId);
    if (room == null) {
      throw Exception('$roomId is Invalid Room id and was sent to socket');
    }
    return InitMessage(
        name: map['name'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        code: map['code'] ?? '',
        room: room,
        webSocket: webSocket);
  }

  @override
  execute() {
    if (room is OwnedRoom) {
      final _room = room as OwnedRoom;
      _room.signWebSocket(code, webSocket);
      //TODO notify alpl about this new user
    }
  }
}

abstract class ActionMessage extends SocketMessage {
  ActionMessage(WebSocketChannel webSocket) : super(webSocket);
}

class SendFileMessage extends ActionMessage {
  final Room room;
  final String fileUrl;
  final String fileId;
  final int size;

  SendFileMessage({
    required this.room,
    required this.fileUrl,
    required this.fileId,
    required this.size,
    required WebSocketChannel webSocket,
  }) : super(webSocket);

  @override
  execute() {
    if (room is OwnedRoom) {
      final _room = room as OwnedRoom;
      _room.addFile(DownloadableFile(id: fileId, url: fileUrl, size: size));
      //TODO notify all about this new file
    }
  }

  factory SendFileMessage.fromMap(
      Map<String, dynamic> map, WebSocketChannel webSocket) {
    final roomId = map['roomId'];
    final room = ICommand.sAppModel.accessibleRoomWithId(roomId);
    if (room == null) {
      throw Exception('$roomId is Invalid Room id and was sent to socket');
    }
    return SendFileMessage(
      room: room,
      fileUrl: map['fileUrl'] ?? '',
      size: map['size']?.toInt() ?? 0,
      webSocket: webSocket,
      fileId: map['fileId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': room.id,
      'fileUrl': fileUrl,
      'size': size,
      'fileId': fileId,
    };
  }
}

class ActionMessageFactory {
  ActionMessage? fromMap(Map<String, Object?> map, WebSocketChannel webSocket) {
    switch ('action') {
      case 'send-file':
        return SendFileMessage.fromMap(map, webSocket);
      default:
        return null;
    }
  }
}

class MessageFactory {
  SocketMessage? fromMap(Map<String, Object?> map, WebSocketChannel webSocket) {
    final message = map['message'] as Map<String, Object?>;
    switch (map['type']) {
      case 'init':
        return InitMessage.fromMap(message, webSocket);
      case 'action':
        return ActionMessageFactory().fromMap(map, webSocket);
      default:
        return null;
    }
  }
}

class SocketServer {
  late final shelf.Handler handler;
  AppModel _appModel;
  Set<OwnedRoom> get _rooms => _appModel.myRooms;

  void _handleMessage(Map<String, Object?> map, WebSocketChannel ws) {
    try {
      final message = MessageFactory().fromMap(map, ws);
      message?.execute();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  SocketServer(this._appModel) {
    handler = webSocketHandler((WebSocketChannel ws) {
      ws.stream.listen((message) {
        _handleMessage(jsonDecode(message), ws);
      });
    });
  }
}
