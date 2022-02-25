import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shair/app_globals.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

class BootStrapCommand extends ICommand {
  @override
  execute() async {
    print('current ip ${await wifiDevices.currentDevice}');
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
      Permission.storage,
    ].request();

    if (statuses.values.any((status) => status.isDenied)) {
      throw Exception('Couldn\'t access Storage');
    }
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
        final appDir = await path_provider.getExternalStorageDirectory();
        if (appDir != null) {
          dir = Directory(appDir.path.split('/Android/').first);
        }
      }
      dir ??= await path_provider.getApplicationDocumentsDirectory();
      dir = Directory(path.join(dir.path, 'Shair'));
      AppGlobals.config.setDefaultDownloadPath(dir);
    }
    appModel.actionsStream.listen((action) {
      action.execute();
    });
  }
}
