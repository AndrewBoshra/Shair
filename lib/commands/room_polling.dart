import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/core/failures.dart';
import 'package:shair/data/room.dart';
import 'package:shair/services/network_devices.dart';

const _kCoolUpDuration = Duration(milliseconds: 1000);

class RoomPollingCommand extends CancelableCommand {
  bool _isPollingRooms = false;
  Set<Room> _lastPollRooms = {};

  @override
  void cancel() {
    debugPrint('Stop Polling');
    _isPollingRooms = false;
  }

  Future<Either<Failure, Set<Room>>> _fetchRooms() async {
    var _rooms = <Room>{};

    final devicesEither = await WifiNetworkDevices.devicesStream;
    return devicesEither.fold(left, (devices) async {
      final _currentPollDevices = <Device>{};

      await for (final device in devices) {
        _currentPollDevices.add(device);
        var deviceRoomsEither = await client.getRooms(device);
        deviceRoomsEither.fold(left, _rooms.addAll);
      }

      ///this happens because a bug in network_tools
      ///in this case we just return the previous one
      if (_currentPollDevices.isNotEmpty) {
        _lastPollRooms = _rooms;
      }

      return right(_lastPollRooms);
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
      final rooms = _fetchRooms();
      final futures =
          await Future.wait([rooms, Future.delayed(_kCoolUpDuration)]);

      appModel.availableRooms = futures.first;
      debugPrint('finished _fetchRooms');
      return _isPollingRooms;
    });
  }
}
