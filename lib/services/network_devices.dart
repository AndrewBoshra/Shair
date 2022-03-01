import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shair/core/failures.dart';
import 'package:shair/services/server.dart';
import 'package:shair/utils/utils.dart';
import 'package:lan_scanner/lan_scanner.dart' as lan_scanner;

const kPort = 4560;

class Device {
  final String ip;
  String get url => 'http://$ip:$kPort';
  String get imageUrl => '$url${RestServer.userImagePath}';
  String get socketUrl => 'ws://$ip:$kPort';
  Device(this.ip);

  Map<String, dynamic> toMap() {
    return {
      'ip': ip,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map, {WebSocket? ws}) {
    return Device(
      map['ip'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

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

abstract class WifiNetworkDevices {
  // final Set<Device> _devices = {};
  static Future<bool> get canCreateRoom async => (await _myIp).isRight();
  static Future<Either<Failure, String>> get _myIp async {
    try {
      final ip = await (NetworkInfo().getWifiIP());
      if (ip == null || ip == '') {
        throw PlatformException(
          message: 'Couldn\'t get device ip',
          code: '5023',
        );
      }
      return right(ip.replaceAllMapped(RegExp('[١-٩]'), arabicToEnglish));
    } on PlatformException catch (e) {
      return left(
        Failure(
            'Network Error please make sure you are connected to a network', e),
      );
    }
  }

  static Future<Either<Failure, Stream<Device>>> get devicesStream async {
    final ipEither = await _myIp;
    return ipEither.fold(left, (ip) async {
      final String subnet = ip.substring(0, ip.lastIndexOf('.'));
      final scanner = lan_scanner.LanScanner();

      final stream = scanner.icmpScan(
        subnet,
        scanThreads: 4,
        progressCallback: print,
        timeout: const Duration(seconds: 3),
      );
      return right(
        stream.where((dev) => dev.ip != ip).map((dev) => Device(dev.ip)),
      );
    });
  }

  static Future<Either<Failure, List<Device>>> get devices async {
    final dStream = await devicesStream;
    return dStream.fold(left, (stream) async {
      return right(await stream.toList());
    });
  }

  static Future<Either<Failure, Device>> get currentDevice async {
    final ip = await _myIp;
    return ip.fold(left, (ip) => right(Device(ip)));
  }
}
