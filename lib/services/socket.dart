import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';

abstract class SocketMessage extends ICommand {
  final JoinedRoom room;
  final WebSocketChannel webSocket;
  SocketMessage(
    this.room,
    this.webSocket,
  );

  Map<String, dynamic> toMap();
  @override
  execute() {
    if (room is OwnedRoom) {
      final _room = room as OwnedRoom;
      if (ownerExecute(_room)) {
        _room.notifyAll(this);
      }
      appModel.notify();
    } else {
      joinedExecute(room);
    }
  }

  ///executed if the current device is the host of this room
  ///
  ///if this function returns true this all users will be notified about this action

  bool ownerExecute(OwnedRoom room);

  joinedExecute(JoinedRoom room);
}

class InitMessage extends SocketMessage {
  final String name;
  final String imageUrl;
  final String code;
  InitMessage({
    required this.name,
    required this.imageUrl,
    required this.code,
    required JoinedRoom room,
    required WebSocketChannel webSocket,
  }) : super(room, webSocket);

  @override
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
  joinedExecute(JoinedRoom room) {
    // TODO: implement joinedExecute
  }

  @override
  bool ownerExecute(OwnedRoom room) {
    return room.signWebSocket(code, webSocket);
  }
}

abstract class ActionMessage extends SocketMessage {
  ActionMessage(JoinedRoom room, WebSocketChannel webSocket)
      : super(room, webSocket);
}

class SendFileMessage extends ActionMessage {
  final String fileUrl;
  final String fileId;
  final int size;

  SendFileMessage({
    required JoinedRoom room,
    required this.fileUrl,
    required this.fileId,
    required this.size,
    required WebSocketChannel webSocket,
  }) : super(room, webSocket);

  @override
  bool ownerExecute(OwnedRoom room) {
    // check if this user can send this file
    final canSend =
        room.participants.any((user) => user.webSocket == webSocket);
    if (!canSend) return false;
    final added =
        room.addFile(DownloadableFile(id: fileId, url: fileUrl, size: size));
    return added;
  }

  @override
  joinedExecute(JoinedRoom room) {
    //TODO implement this
  }

  factory SendFileMessage.fromMap(
      Map<String, dynamic> map, WebSocketChannel webSocket) {
    final roomId = map['roomId'] as String?;
    final room = ICommand.sAppModel.accessibleRoomWithId(roomId ?? '');
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

  @override
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
    switch (map['type']) {
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
        return ActionMessageFactory().fromMap(message, webSocket);
      default:
        return null;
    }
  }
}

class SocketServer {
  late final shelf.Handler handler;

  void _handleMessage(Map<String, Object?> map, WebSocketChannel ws) {
    try {
      final message = MessageFactory().fromMap(map, ws);
      message?.execute();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  SocketServer() {
    handler = webSocketHandler((WebSocketChannel ws) {
      ws.stream.listen((message) {
        _handleMessage(jsonDecode(message), ws);
      });
    });
  }
}
