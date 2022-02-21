import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:shair/app_globals.dart';
import 'package:shair/commands/abstract_command.dart';

class BootStrapCommand extends ICommand {
  @override
  execute() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await DesktopWindow.setMinWindowSize(const Size(400, 800));
      await DesktopWindow.setMaxWindowSize(const Size(600, 1000000));
    }
    AppGlobals.server.start();
    await AppGlobals.config.load();
    appModel.actionsStream.listen((action) {
      action.execute();
    });
  }
}
