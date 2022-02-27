import 'package:flutter/cupertino.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';
import 'package:shair/services/socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class UserLeftRoomMessage extends ActionMessage {
  UserLeftRoomMessage(JoinedRoom room, WebSocketChannel senderWebSocket)
      : super(room, senderWebSocket);

  @override
  String get actionType => kActionType;
  static const kActionType = 'leave-room';
  @override
  joinedExecute(JoinedRoom room) {
    room.removeParticipantWithWebSocket(senderWebSocket!);
  }

  @override
  ownerExecute(OwnedRoom room) {
    joinedExecute(room);
    room.notifyAll(this);
  }

  @override
  Map<String, dynamic> toMapImpl() {
    return {
      'code': room.userWithWebSocket(senderWebSocket!),
    };
  }

  factory UserLeftRoomMessage.fromMap(
      Map<String, dynamic> map, WebSocketChannel ws) {
    final roomId = map['roomId'] as String?;
    final room = ICommand.sAppModel.accessibleRoomWithId(roomId ?? '');
    return UserLeftRoomMessage(room!, ws);
  }
}

class LeaveRoomCommand extends ICommand {
  final JoinedRoom joinedRoom;
  final BuildContext context;

  LeaveRoomCommand(this.joinedRoom, this.context);
  @override
  execute() async {
    assert(!joinedRoom.isOwned);
    await joinedRoom.leave();
    appModel.removeFromJoinedRooms(joinedRoom);
    Navigator.of(context).pop();
  }
}
