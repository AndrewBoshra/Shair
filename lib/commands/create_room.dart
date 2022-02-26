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
  Future<Room> execute() async {
    final config = AppGlobals.config;
    final device = await wifiDevices.currentDevice;
    final room = OwnedRoom(
        name: name,
        isLocked: isLocked,
        roomImage: image != null
            ? CharacterImage(
                path: image,
              )
            : null,
        currentUser: RoomUser.formConfig(config, imgUrl: device.imageUrl),
        owner: device);
    appModel.addRoomToMyRooms(room);
    return room;
  }
}
