import 'package:flutter/src/widgets/framework.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';

class JoinRoomCommand extends ICommand {
  final Room room;
  JoinRoomCommand(BuildContext context, this.room) : super(context: context);

  @override
  execute() {
    // TODO: implement execute
    throw UnimplementedError();
  }
}
