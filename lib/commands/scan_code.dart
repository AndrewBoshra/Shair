import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/dialogs/show_dialog.dart';

class ScanQrCommand extends ICommand {
  final BuildContext context;

  ScanQrCommand(this.context);
  @override
  execute() async {
    await Dialogs.showQrScanner(context);
  }
}
