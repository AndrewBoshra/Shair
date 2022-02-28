import 'package:dartz/dartz.dart';
import 'package:shair/app_globals.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/core/failures.dart';
import 'package:shair/data/room.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/styled_components/avatar.dart';

class CreateRoomCommand extends ICommand {
  CreateRoomCommand(this.name, this.image, this.isLocked);
  final String name;
  final String? image;
  final bool isLocked;
  Future<Either<Failure, OwnedRoom>> _createRoom(Device device) async {
    final room = OwnedRoom(
      name: name,
      isLocked: isLocked,
      roomImage: image != null
          ? CharacterImage(
              path: image,
            )
          : null,
      currentUser: RoomUser.formConfig(config, imgUrl: device.imageUrl),
      owner: device,
    );
    appModel.addRoomToMyRooms(room);
    RootNavigator.toRoomScreen(room, pop: true);
    return right(room);
  }

  @override
  Future<Either<Failure, OwnedRoom>> execute() async {
    var device = await wifiDevices.currentDevice;

    ///we will create room in both cases so that it works with hotSpot devices
    return device.fold((l) => _createRoom(Device('0.0.0.0')), _createRoom);
  }
}
