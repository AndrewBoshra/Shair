import 'dart:convert';
import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shair/app_globals.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:shair/data/assets.dart';

class BootStrapCommand extends ICommand {
  Future _initImages() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('assets/characters'))
        .toList();
    final characterImagesDir = await ImageAssets.cachedCharactersDir;
    for (final imagePath in imagePaths) {
      final iPath =
          path.join(characterImagesDir.path, path.basename(imagePath));
      final imageFile = File(iPath);
      if (await imageFile.exists()) continue;

      final imgData = await rootBundle.load(imagePath);
      await imageFile.create();

      imageFile.writeAsBytes(imgData.buffer
          .asUint8List(imgData.offsetInBytes, imgData.lengthInBytes));
    }
  }

  @override
  Future<void> execute() async {
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

    _initImages();
  }
}
