import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/app.dart';
import 'package:shair/app_globals.dart';
import 'package:shair/commands/bootstrap.dart';
import 'package:shair/constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AppGlobals.config),
        ChangeNotifierProvider.value(value: AppGlobals.appModel),
        ChangeNotifierProvider.value(value: lightTheme),
      ],
      child: const App(),
    ),
  );
}
