import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/app.dart';
import 'package:shair/app_globals.dart';
import 'package:shair/constants/colors.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AppGlobals.config),
        ChangeNotifierProvider.value(value: AppGlobals.appModel),
        Provider.value(value: AppGlobals.wifiDevices),
        ChangeNotifierProvider.value(value: lightTheme),
      ],
      child: const App(),
    ),
  );
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    doWhenWindowReady(() {
      const minSize = Size(400, 800);
      appWindow.minSize = minSize;
      appWindow.maxSize = Size(minSize.width, 100000);
    });
  }
}
