import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shair/actions/abstract.dart';
import 'package:shair/commands/room_polling.dart';
import 'package:shair/data/room.dart';

///class Containing general app state
///
class AppModel extends ChangeNotifier {
  Set<Room> _availableRooms = {};
  final Set<Room> _myRooms = {};
  final Set<Room> _joinedRooms = {};

  //*****************************************/
  ///Actions Stream used when the server requires an action to be taken from the user
  ///
  ///ex: join request
  final StreamController<IActionRequired> _actionsSController =
      StreamController.broadcast();

  AppModel();

  Stream<IActionRequired> get actionsStream => _actionsSController.stream;
  Sink<IActionRequired> get actionsSink => _actionsSController.sink;

  ///Response Stream used when the user respond to an action required from the server
  ///
  ///ex: accept join request
  final StreamController<IActionResponse> _responseSController =
      StreamController.broadcast();
  Stream<IActionResponse> get responseStream => _responseSController.stream;
  Sink<IActionResponse> get responseSink => _responseSController.sink;

  ///available Rooms
  UnmodifiableSetView<Room> get availableRooms =>
      UnmodifiableSetView(_availableRooms);

  UnmodifiableSetView<Room> get myRooms => UnmodifiableSetView(_myRooms);

  UnmodifiableSetView<Room> get joinedRooms =>
      UnmodifiableSetView(_joinedRooms);

  Set<Room> get accessableRooms => {...joinedRooms, ..._myRooms};

  set availableRooms(Set<Room> rooms) {
    _availableRooms = rooms;
    notifyListeners();
  }

  void addRoomToMyRooms(Room room) {
    _myRooms.add(room);
    notifyListeners();
  }

  void addRoomToJoinedRooms(Room room) {
    _joinedRooms.add(room);
    notifyListeners();
  }

  /// Room Polling
  RoomPollingCommand? _currentPollCommand;
  set currentPollCommand(RoomPollingCommand command) {
    _currentPollCommand ??= command;
  }

  void cancelRoomPolling() {
    _currentPollCommand?.cancel();
    _currentPollCommand = null;
  }

  /// methods
  Room? accessableRoowmWithId(String id) {
    final rooms = accessableRooms.where((room) => room.id == id);
    return rooms.isNotEmpty ? rooms.first : null;
  }

  static AppModel of(BuildContext c, {bool listen = true}) =>
      Provider.of(c, listen: listen);
}

// import 'dart:collection';
// import 'dart:io';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:shair/data/room.dart';
// import 'package:shair/data/shared_file.dart';
// import 'package:shair/models/client.dart';
// import 'package:shair/models/generator.dart';
// import 'package:shair/models/network_devices.dart';
// import 'package:shair/models/server.dart';

// const _kPollDuration = Duration(milliseconds: 2000);

// abstract class AppModel extends ChangeNotifier {
//   UnmodifiableSetView<Room> get rooms;
//   UnmodifiableSetView<Room> get myRooms;
//   UnmodifiableSetView<Room> get joinedRooms;
//   Future<Room> create(String name, String? image, bool isLocked);
//   Future<bool> join(Room room);
//   Future<void> leave(Room room);
//   Future<void> shareFile(PlatformFile file, Room room);
//   Future<void> download(SharedFile file);
//   void pollRooms();
//   void stopPollingRooms();
//   Room? getJoinedRoomWithId(String id);
// }

// class AppModelRest extends AppModel {
//   final Client client;
//   final Server server;
//   bool _ispollingRooms = false;
//   NetworkDevices networkDevices;

//   /// all rooms available on the network
//   ///
//   Set<Room> _rooms = {};

//   /// all rooms that this user joined
//   ///
//   final Set<Room> _joinedRooms = {};

//   /// all rooms that created by this user
//   ///
//   final Set<Room> _myRooms = {};

//   AppModelRest(this.client, this.server, this.networkDevices);

//   Future<List<Room>> _fetchRooms() async {
//     _rooms = {};
//     final devices = await networkDevices.devices;
//     for (final device in devices) {
//       if (await client.isActive(device)) {
//         final deviceRooms = await client.getRooms(device);
//         _rooms.addAll(deviceRooms);
//       }
//     }
//     return _rooms.toList();
//   }

//   @override
//   UnmodifiableSetView<Room> get rooms => UnmodifiableSetView(_rooms);
//   @override
//   UnmodifiableSetView<Room> get joinedRooms =>
//       UnmodifiableSetView({..._joinedRooms, ..._myRooms});
//   @override
//   UnmodifiableSetView<Room> get myRooms => UnmodifiableSetView<Room>(_myRooms);

//   @override
//   Room? getJoinedRoomWithId(String id) {
//     final room =
//         joinedRooms.firstWhere((room) => room.id == id, orElse: Room.empty);
//     return room.isValid ? room : null;
//   }

//   @override
//   Future<void> download(SharedFile file) {
//     // TODO: implement download
//     throw UnimplementedError();
//   }

//   @override
//   Future<bool> join(Room room) async {
//     // if (room.owner == await networkDevices.currentDevice) {
//     //   return true;
//     // }
//     room.idInRoom = Generator.userId;
//     final acceptance = await client.askToJoin(room);

//     if (acceptance.isAccepted) {
//       room.idInRoom = acceptance.idInRoom;
//       // To get files in this room
//       final fRoom = await client.getRoomDetails(room);
//       _joinedRooms.add(fRoom);
//       return true;
//     }
//     return false;
//   }

//   @override
//   Future<void> leave(Room room) {
//     // TODO: implement leave
//     throw UnimplementedError();
//   }

//   Future<void> _serveFile(PlatformFile file, Room room) async {
//     await server.shareFile(File(file.path!), room);
//   }

//   @override
//   Future<void> shareFile(PlatformFile file, Room room) async {
//     print('share : ${file.path} ${file.size}');
//     if (room.owner == await networkDevices.currentDevice) {
//       await _serveFile(file, room);
//       await client.notifyParticipantsAboutFile(file, room);
//     } else {
//       if (await client.askHostToShareFile(file, room)) {
//         await _serveFile(file, room);
//       }
//     }
//   }

//   @override
//   void pollRooms() {
//     if (_ispollingRooms) return;
//     _ispollingRooms = true;
//     Future.doWhile(() async {
//       await _fetchRooms();
//       debugPrint('finished _fetchRooms');
//       notifyListeners();
//       await Future.delayed(_kPollDuration);
//       return _ispollingRooms;
//     });
//   }

//   @override
//   void stopPollingRooms() {
//     _ispollingRooms = false;
//     debugPrint('stopped polling');
//   }

//   @override
//   Future<Room> create(String name, String? image, bool isLocked) async {
//     final room = Room(
//       await networkDevices.currentDevice,
//       name: name,
//       isLocked: isLocked,
//       image: image,
//     );
//     if (server.createRoom(room)) {
//       _myRooms.add(room);
//     }
//     return room;
//   }
// }
