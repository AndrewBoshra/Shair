import 'package:flutter/cupertino.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';
import 'package:shair/dialogs/show_dialog.dart';

class ShowJoinCodeCommand extends ICommand {
  final BuildContext context;
  final Room room;

  ShowJoinCodeCommand(
    this.context,
    this.room,
  );
  @override
  execute() {
    Dialogs.showJoinCodeDialog(context, room.idInRoom ?? '');
  }
}
