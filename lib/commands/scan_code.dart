import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/screens/qr_code.dart';

class ScanQrCommand extends ICommand {
  final BuildContext context;

  ScanQrCommand(this.context);
  @override
  execute() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const QrScanner(),
    ));

    // client.join(room)
  }
}
