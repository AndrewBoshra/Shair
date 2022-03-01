import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/core/failures.dart';
import 'package:shair/data/room.dart';
import 'package:shair/services/network_devices.dart';

const _kCoolUpDuration = Duration(milliseconds: 3000);

class RoomPollingCommand extends CancelableCommand {
  bool _isPollingRooms = false;
  StreamSubscription? _deviceStreamSub;
  @override
  void cancel() {
    debugPrint('Stop Polling');
    _deviceStreamSub?.cancel();
    _isPollingRooms = false;
  }

  Future<Either<Failure, Set<Room>>> _fetchRooms() async {
    var _rooms = <Room>{};

    final devicesEither = await WifiNetworkDevices.devicesStream;
    return devicesEither.fold(left, (devices) async {
      _deviceStreamSub = devices.listen((device) async {
        var deviceRoomsEither = await client.getRooms(device);

        deviceRoomsEither.fold(left, (rooms) {
          if (rooms.isNotEmpty) {
            _rooms.addAll(rooms);
            appModel.availableRooms = right(_rooms);
          }
        });
      });
      await _deviceStreamSub!.asFuture();

      return right(_rooms);
    });
  }

  ///returns a future that ends with the first poll
  @override
  Future execute() async {
    debugPrint('started polling');
    appModel.currentPollCommand = this;
    _isPollingRooms = true;
    appModel.availableRooms = await _fetchRooms();

    Future.doWhile(() async {
      await Future.delayed(_kCoolUpDuration);
      final rooms = await _fetchRooms();
      appModel.availableRooms = rooms;
      debugPrint('finished _fetchRooms');
      return _isPollingRooms;
    });
  }
}
