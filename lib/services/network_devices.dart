import 'dart:convert';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';

const kPort = 4560;

class Device {
  final String ip;
  String get url => 'http://$ip:$kPort';
  Device(this.ip);

  Map<String, dynamic> toMap() {
    return {
      'ip': ip,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      map['ip'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Device.fromJson(String source) => Device.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Device && other.ip == ip;
  }

  @override
  int get hashCode => ip.hashCode;
  @override
  String toString() {
    return 'Device ip:$ip';
  }
}

abstract class NetworkDevices {
  Future<List<Device>> get devices;
  Future<Device> get currentDevice;
}

class WifiNetworkDevices implements NetworkDevices {
  final Set<Device> _devices = {};
  @override
  Future<List<Device>> get devices async {
    String? ip = await (NetworkInfo().getWifiIP());
    ip ??= '192.168.1.0';
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final stream = HostScanner.discover(subnet,
        firstSubnet: 1, lastSubnet: 50, progressCallback: (progress) {});

    final hosts = await stream.toList();
    _devices.addAll(hosts.map((host) => Device(host.ip)));
    _devices.add(Device(ip));
    return _devices.toList();
  }

  @override
  Future<Device> get currentDevice async {
    final ip = await (NetworkInfo().getWifiIP());
    if (ip == null) throw Exception('Couldn\'t get device ip');
    return Device(ip);
  }
}