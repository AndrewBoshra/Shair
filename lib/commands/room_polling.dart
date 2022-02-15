import 'package:flutter/material.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';

const _kCoolUpDuration = Duration(milliseconds: 1000);

class RoomPollingCommand extends CancelableCommand {
  bool _isPollingRooms = false;
  @override
  void cancel() {
    debugPrint('Stop Polling');
    _isPollingRooms = false;
  }

  Future<Set<Room>> _fetchRooms() async {
    var _rooms = <Room>{};
    final devices = await wifiDevices.devices;
    for (final device in devices) {
      var deviceRooms = await client.getRooms(device);
      deviceRooms ??= [];
      _rooms.addAll(deviceRooms);
    }
    return _rooms;
  }

  @override
  Future execute() async {
    appModel.currentPollCommand = this;
    _isPollingRooms = true;

    Future.doWhile(() async {
      final rooms = await _fetchRooms();
      appModel.availableRooms = rooms;
      debugPrint('finished _fetchRooms');
      await Future.delayed(_kCoolUpDuration);
      return _isPollingRooms;
    });
  }
}
