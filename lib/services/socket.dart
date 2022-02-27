import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shair/app_globals.dart';
import 'package:shair/commands/leave_room.dart';
import 'package:shair/commands/share_file.dart';
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
  final WebSocketChannel? senderWebSocket;
  SocketMessage(this.room, this.senderWebSocket, this.notifyHost);

  Map<String, dynamic> toMap();
  String toJson() => jsonEncode(toMap());
  @override
  execute() {
    if (room.isOwned) {
      final _room = room as OwnedRoom;
      ownerExecute(_room);
    } else {
      joinedExecute(room);
      if (notifyHost) {
        room.sendToHost(this);
      }
    }
    //update screen
    appModel.notify();
  }

  ///executed if the current device is the host of this room
  ///
  ///if this function returns true this all users will be notified about this action

  ownerExecute(OwnedRoom room);
  joinedExecute(JoinedRoom room);
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
    WebSocketChannel? senderWebSocket,
  }) : super(room, senderWebSocket, notifyHost);

  factory InitSocketMessage.formConfig(
      Config config, JoinedRoom room, bool notifyHost, String userImageUrl) {
    assert(room.idInRoom != null,
        'You must  have inRoomId to be able to send to room host');
    assert(room.webSocket != null,
        'You must connect to socket before you send message to host');

    return InitSocketMessage(
      name: config.name,
      imageUrl: userImageUrl,
      code: room.idInRoom!,
      room: room,
      notifyHost: notifyHost,
    );
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
      Map<String, dynamic> map, WebSocketChannel? webSocket) {
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
      senderWebSocket: webSocket,
    );
  }

  @override
  ownerExecute(OwnedRoom room) {
    if (senderWebSocket == null) return;
    bool added =
        room.signWebSocket(code, senderWebSocket!, image: imageUrl, name: name);
    if (added) {
      room.notifyAll(this);
    }
  }

  @override
  joinedExecute(JoinedRoom room) {
    //add this user to the room so that he can download files hosted by this user.
    room.add(code);
  }
}

abstract class ActionMessage extends SocketMessage {
  ActionMessage(JoinedRoom room, WebSocketChannel? senderWebSocket,
      [bool notifyHost = false])
      : super(room, senderWebSocket, notifyHost);
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

class ActionMessageFactory {
  ActionMessage? fromMap(
      Map<String, Object?> map, WebSocketChannel? webSocket) {
    switch (map['type']) {
      case ShareFileMessage.kActionType:
        return ShareFileMessage.fromMap(map, webSocket);
      case UserLeftRoomMessage.kActionType:
        assert(
            webSocket != null, 'websocket must not be null to leave the room');
        return UserLeftRoomMessage.fromMap(map, webSocket!);
      default:
        return null;
    }
  }
}

class MessageFactory {
  SocketMessage? fromMap(
      Map<String, Object?> map, WebSocketChannel? webSocket) {
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

class SocketService {
  late final shelf.Handler handler;

  void handleMessage(String message, [WebSocketChannel? ws]) {
    final map = jsonDecode(message);
    try {
      final message = MessageFactory().fromMap(map, ws);
      message?.execute();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  SocketService() {
    handler = webSocketHandler((WebSocketChannel ws) async {
      ws.stream.listen((message) {
        handleMessage(message, ws);
      });
      await ws.sink.done;
      final rooms = AppGlobals.appModel.joinedRoomWithWebSocket(ws);
      for (final room in rooms) {
        UserLeftRoomMessage(room, ws).execute();
      }
    });
  }
}
