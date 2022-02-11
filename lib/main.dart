import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/app.dart';
import 'package:shair/constants/colors.dart';
import 'package:shair/data/config.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/models/client.dart';
import 'package:shair/models/network_devices.dart';
import 'package:shair/models/server.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Config()),
        ChangeNotifierProvider<AppModel>.value(
            value:
                AppModelRest(RestClient(), RestServer(), WifiNetworkDevices())),
        ChangeNotifierProvider.value(value: lightTheme),
      ],
      child: const App(),
    ),
  );
}
