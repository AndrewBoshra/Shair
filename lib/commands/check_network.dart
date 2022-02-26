import 'package:shair/commands/abstract_command.dart';

class CheckNetworkStateCommand extends ICommand {
  @override
  Future<bool> execute() async {
    final device = await wifiDevices.currentDevice;
    return device.isRight();
  }
}
