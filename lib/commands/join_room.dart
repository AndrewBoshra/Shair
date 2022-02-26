import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/config.dart';
import 'package:shair/data/room.dart';
import 'package:shair/dialogs/show_dialog.dart';
import 'package:shair/dialogs/snackbars.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/services/generator.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/services/server.dart';
import 'package:shair/services/socket.dart';

class JoinRoomCommand extends ICommand {
  final Room room;
  final BuildContext context;

  JoinRoomCommand(this.context, this.room);

  _connectToRoom(JoinedRoom room, Device device) async {
    final wsEither = await client.join(room);
    wsEither.fold(id, (ws) {
      room.webSocket = ws;
      ws.listen((event) {
        server.socketService.handleMessage(event);
      });
      InitSocketMessage.formConfig(
        config,
        room,
        true,
        device.url + RestServer.userImagePath,
      ).execute();
      appModel.addRoomToJoinedRooms(room);
      appModel.cancelRoomPolling();
      RootNavigator.toRoomScreen(room, pop: true);
    });
  }

  @override
  execute() async {
    if (room.isOwned) {
      return;
    }
    String? idInRoom;
    if (room.isLocked) {
      idInRoom = Generator.userId;
      Dialogs.showJoinCodeDialog(context, idInRoom);
    }

    final deviceEither = await wifiDevices.currentDevice;

    deviceEither.fold(left, (device) async {
      final askRes = await client.askToJoin(room, config, idInRoom, device.ip);
      await askRes.fold(
        (f) {
          SnackBars.show(
            context,
            SnackBars.error(
                context, 'Your Request to join ${room.name} was rejected'),
          );
        },
        (room) => _connectToRoom(room, device),
      );
    });
  }
}
