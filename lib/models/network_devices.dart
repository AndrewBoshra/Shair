import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';

const _kPort = 4560;

class Device {
  final String ip;
  String get url => 'http://$ip:$_kPort';
  Device(this.ip);
}

abstract class NetworkDevices {
  Future<List<Device>> get devices;
}

class WifiNetworkDevices implements NetworkDevices {
  Future<List<Device>> get devices async {
    final String? ip = await (NetworkInfo().getWifiIP());
    if (ip == null) return [];
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final stream = HostScanner.discover(subnet, firstSubnet: 1, lastSubnet: 50,
        progressCallback: (progress) {
      // debugPrint('Progress for host discovery : $progress');
    });

    final hosts = await stream.toList();
    return hosts.map((host) => Device(host.ip)).toSet().toList()
      ..add(Device(ip));
  }
}
