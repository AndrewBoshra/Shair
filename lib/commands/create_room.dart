import 'package:shair/app_globals.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';
import 'package:shair/styled_components/avatar.dart';

class CreateRoomCommand extends ICommand {
  CreateRoomCommand(this.name, this.image, this.isLocked);
  final String name;
  final String? image;
  final bool isLocked;
  @override
  Room execute() {
    final config = AppGlobals.config;
    final room = OwnedRoom(
      name: name,
      isLocked: isLocked,
      roomImage: image != null ? CharacterImage(image!, true) : null,
      currentUser: RoomUser.formConfig(config),
    );
    appModel.addRoomToMyRooms(room);
    return room;
  }
}
