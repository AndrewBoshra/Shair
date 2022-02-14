import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shair/app_globals.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/services/client.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/services/server.dart';

@immutable
abstract class ICommand {
  execute();

  AppModel get appModel => AppGlobals.appModel;
  Server get server => AppGlobals.server;
  Client get client => AppGlobals.client;
  WifiNetworkDevices get wifiDevices => AppGlobals.wifiDevices;
}

abstract class CancelableCommand extends ICommand {
  cancel();
}
