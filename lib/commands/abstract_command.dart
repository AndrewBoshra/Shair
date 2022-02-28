import 'package:shair/app_globals.dart';
import 'package:shair/data/config.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/services/client.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/services/server.dart';

abstract class ICommand {
  execute();

  static AppModel get sAppModel => AppGlobals.appModel;
  static RestServer get sServer => AppGlobals.server;
  static RestClient get sClient => AppGlobals.client;
  static Config get sConfig => AppGlobals.config;

  Config get config => AppGlobals.config;
  AppModel get appModel => AppGlobals.appModel;
  RestServer get server => AppGlobals.server;
  RestClient get client => AppGlobals.client;
}

abstract class CancelableCommand extends ICommand {
  cancel();
}
