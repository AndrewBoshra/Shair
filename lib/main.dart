import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/app.dart';
import 'package:shair/app_globals.dart';
import 'package:shair/commands/bootstrap.dart';
import 'package:shair/constants/colors.dart';
import 'package:shair/data/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BootStrapCommand().execute();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Config()),
        ChangeNotifierProvider.value(value: AppGlobals.appModel),
        ChangeNotifierProvider.value(value: lightTheme),
      ],
      child: const App(),
    ),
  );
}
