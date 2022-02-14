import 'package:file_picker/file_picker.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';

class CreateRoomCommand extends ICommand {
  CreateRoomCommand(this.name, this.image, this.isLocked);
  final String name;
  final String? image;
  final bool isLocked;
  @override
  Room execute() {
    final room = Room(name: name, isLocked: isLocked, image: image);
    appModel.addRoomToMyRooms(room);
    return room;
  }
}
