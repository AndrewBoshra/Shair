import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/config.dart';
import 'package:shair/data/room.dart';
import 'package:shair/dialogs/show_dialog.dart';
import 'package:shair/dialogs/snakbars.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/services/generator.dart';

class JoinRoomCommand extends ICommand {
  final Room room;
  final BuildContext context;
  JoinRoomCommand(this.context, this.room);
  Config get config => context.read<Config>();
  @override
  execute() async {
    //TODO uncomment this
    // if (room.owner == null) {
    //   return;
    // }
    String idInRoom = Generator.userId;
    Dialogs.showJoinCodeDialog(context, idInRoom);
    final device = await wifiDevices.currentDevice;
    final joinRes = await client.askToJoin(room, config, idInRoom, device.ip);

    if (joinRes == null) {
      SnackBars.show(
        context,
        SnackBars.error(
            context, 'Your Request to join ${room.name} was rejected'),
      );
    } else {
      appModel.addRoomToJoinedRooms(joinRes);
      RootNavigator.toRoomScreen(joinRes, pop: true);
    }
  }
}
