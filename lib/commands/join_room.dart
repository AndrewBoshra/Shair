import 'package:flutter/src/widgets/framework.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/commands/show_join_code.dart';
import 'package:shair/data/room.dart';
import 'package:shair/services/generator.dart';

class JoinRoomCommand extends ICommand {
  final Room room;
  final BuildContext context;
  JoinRoomCommand(this.context, this.room);

  @override
  execute() {
    if (room.owner == null) {
      return;
    }
    room.idInRoom = Generator.userId;
    ShowJoinCodeCommand(context, room).execute();
    //client.askToJoin(room);
    // print('should ask to join now');
  }
}
