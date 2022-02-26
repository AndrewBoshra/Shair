import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/core/failures.dart';
import 'package:shair/data/room.dart';

const _kCoolUpDuration = Duration(milliseconds: 1000);

class RoomPollingCommand extends CancelableCommand {
  bool _isPollingRooms = false;
  @override
  void cancel() {
    debugPrint('Stop Polling');
    _isPollingRooms = false;
  }

  Future<Either<Failure, Set<Room>>> _fetchRooms() async {
    var _rooms = <Room>{};

    final devicesEither = await wifiDevices.devices;
    return devicesEither.fold(left, (devices) async {
      for (final device in devices) {
        var deviceRooms = await client.getRooms(device);
        deviceRooms ??= [];
        _rooms.addAll(deviceRooms);
      }
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
      appModel.availableRooms = await _fetchRooms();
      debugPrint('finished _fetchRooms');
      return _isPollingRooms;
    });
  }
}
