import 'package:shair/data/config.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/services/client.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/services/server.dart';

abstract class AppGlobals {
  static final Config config = Config();
  static final AppModel appModel = AppModel();
  static final server = RestServer(appModel);
  static final client = RestClient();
  static final WifiNetworkDevices wifiDevices = WifiNetworkDevices();
}
