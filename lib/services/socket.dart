import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shair/data/config.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';

abstract class SocketMessage extends ICommand {
  final JoinedRoom room;

  /// if true then this command is sent to the host of the room
  /// else then the command is executed without notifying the host (this happen when the host
  /// is the one who sent this command)
  ///
  /// defaults to false
  final bool notifyHost;
  final WebSocketChannel? webSocket;
  SocketMessage(this.room, this.webSocket, this.notifyHost);

  Map<String, dynamic> toMap();
  String toJson() => jsonEncode(toMap());
  @override
  execute() {
    if (room.isOwned) {
      final _room = room as OwnedRoom;
      if (ownerExecute(_room)) {
        _room.notifyAll(this);
        appModel.notify();
      }
    } else {
      joinedExecute(room);
    }
  }

  ///executed if the current device is the host of this room
  ///
  ///if this function returns true this all users will be notified about this action

  bool ownerExecute(OwnedRoom room);
  @mustCallSuper
  joinedExecute(JoinedRoom room) {
    room.sendToHost(this);
  }
}

class InitSocketMessage extends SocketMessage {
  final String? name;
  final String? imageUrl;
  final String code;
  InitSocketMessage({
    this.name,
    this.imageUrl,
    required this.code,
    required JoinedRoom room,
    bool notifyHost = false,
    WebSocketChannel? webSocket,
  }) : super(room, webSocket, notifyHost);

  factory InitSocketMessage.formConfig(Config config, JoinedRoom room) {
    assert(room.idInRoom != null,
        'You must  have inRoomId to be able to send to room host');
    assert(room.webSocket != null,
        'You must connect to socket before you send message to host');
    return InitSocketMessage(
        name: config.name,
        imageUrl: config.character ?? '',
        code: room.idInRoom!,
        room: room);
  }
  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'init',
      'message': {
        'name': name,
        'imageUrl': imageUrl,
        'code': code,
        'roomId': room.id,
      }
    };
  }

  factory InitSocketMessage.fromMap(
      Map<String, dynamic> map, WebSocketChannel webSocket) {
    final roomId = map['roomId'];
    final room = ICommand.sAppModel.accessibleRoomWithId(roomId);
    if (room == null) {
      throw Exception('$roomId is Invalid Room id and was sent to socket');
    }
    return InitSocketMessage(
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      code: map['code'] ?? '',
      room: room,
      webSocket: webSocket,
    );
  }

  // @override
  // joinedExecute(JoinedRoom room) {
  //   // TODO: implement joinedExecute
  //   super.joinedExecute(room);
  // }

  @override
  bool ownerExecute(OwnedRoom room) {
    if (webSocket == null) return false;
    return room.signWebSocket(code, webSocket!);
  }
}

abstract class ActionMessage extends SocketMessage {
  ActionMessage(JoinedRoom room, WebSocketChannel? webSocket,
      [bool notifyHost = false])
      : super(room, webSocket, notifyHost);
  String get actionType;

  Map<String, dynamic> toMapImpl();

  @override
  Map<String, dynamic> toMap() {
    return actionToMap(toMapImpl());
  }

  Map<String, dynamic> actionToMap(Map<String, dynamic> map) {
    return {
      'type': 'action',
      'message': {'type': actionType, ...map}
    };
  }
}

class ShareFileMessage extends ActionMessage {
  final String fileUrl;
  final String fileId;
  final int? size;
  final String name;

  ShareFileMessage({
    required JoinedRoom room,
    required this.name,
    required this.fileUrl,
    required this.fileId,
    required this.size,
    required WebSocketChannel? webSocket,
    bool notifyHost = false,
  }) : super(room, webSocket, notifyHost);
  factory ShareFileMessage.fromDownloadableFile(
      DownloadableFile file, JoinedRoom room,
      [WebSocketChannel? webSocket]) {
    return ShareFileMessage(
      room: room,
      fileUrl: file.url,
      fileId: file.id,
      name: file.name,
      size: file.size,
      webSocket: webSocket,
    );
  }
  @override
  bool ownerExecute(OwnedRoom room) {
    // check if this user can send this file
    final canSend =
        room.participants.any((user) => user.webSocket == webSocket);
    if (!canSend) return false;
    final added = room.addFile(
        DownloadableFile(id: fileId, name: name, url: fileUrl, size: size));
    return added;
  }

  factory ShareFileMessage.fromMap(
      Map<String, dynamic> map, WebSocketChannel webSocket) {
    final roomId = map['roomId'] as String?;
    final room = ICommand.sAppModel.accessibleRoomWithId(roomId ?? '');
    if (room == null) {
      throw Exception('$roomId is Invalid Room id and was sent to socket');
    }
    return ShareFileMessage(
      room: room,
      fileUrl: map['fileUrl'] ?? '',
      size: map['size']?.toInt() ?? 0,
      webSocket: webSocket,
      fileId: map['fileId'],
      name: map['name'],
    );
  }

  @override
  String get actionType => 'send-file';

  @override
  Map<String, dynamic> toMapImpl() {
    return {
      'roomId': room.id,
      'fileUrl': fileUrl,
      'size': size,
      'fileId': fileId,
      'name': name,
    };
  }
}

class ActionMessageFactory {
  ActionMessage? fromMap(Map<String, Object?> map, WebSocketChannel webSocket) {
    switch (map['type']) {
      case 'send-file':
        return ShareFileMessage.fromMap(map, webSocket);
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
        return InitSocketMessage.fromMap(message, webSocket);
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
        print('You have got a message $message');
        _handleMessage(jsonDecode(message), ws);
      });
    });
  }
}
