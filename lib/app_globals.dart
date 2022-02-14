import 'package:shair/models/app_model.dart';
import 'package:shair/services/client.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/services/server.dart';

abstract class AppGlobals {
  static final AppModel appModel = AppModel();
  static final Server server = RestServer(appModel);
  static final Client client = RestClient();
  static final WifiNetworkDevices wifiDevices = WifiNetworkDevices();
}
