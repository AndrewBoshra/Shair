import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/app.dart';
import 'package:shair/data/config.dart';
import 'package:shair/models/app_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Config()),
        ChangeNotifierProvider<AppModel>.value(value: AppModelMock()),
      ],
      child: const App(),
    ),
  );
}
