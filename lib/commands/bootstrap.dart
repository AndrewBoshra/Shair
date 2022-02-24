import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:shair/app_globals.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class BootStrapCommand extends ICommand {
  @override
  execute() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await DesktopWindow.setMinWindowSize(const Size(400, 800));
      await DesktopWindow.setMaxWindowSize(const Size(600, 1000000));
    }
    AppGlobals.server.start();
    await AppGlobals.config.load();
    if (AppGlobals.config.downloadDir == null) {
      Directory? dir;
      if (Platform.isWindows) {
        dir = await path_provider.getDownloadsDirectory();
      } else if (Platform.isAndroid) {
        dir = await path_provider.getExternalStorageDirectory();
      }
      dir ??= await path_provider.getApplicationDocumentsDirectory();
      AppGlobals.config.setDefaultDownloadPath(dir.path);
    }
    appModel.actionsStream.listen((action) {
      action.execute();
    });
  }
}
