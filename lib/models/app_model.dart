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
  final Set<OwnedRoom> _myRooms = {
    OwnedRoom(
      isLocked: true,
      name: 'Test',
      id: '1',
      participants: {
        RoomUser(code: '123456'),
      },
    )
  };
  final Set<JoinedRoom> _joinedRooms = {};

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

  UnmodifiableSetView<OwnedRoom> get myRooms => UnmodifiableSetView(_myRooms);

  UnmodifiableSetView<JoinedRoom> get joinedRooms =>
      UnmodifiableSetView(_joinedRooms);

  Set<JoinedRoom> get accessibleRooms => {...joinedRooms, ..._myRooms};

  set availableRooms(Set<Room> rooms) {
    _availableRooms = rooms;
    notifyListeners();
  }

  void addRoomToMyRooms(OwnedRoom room) {
    _myRooms.add(room);
    notifyListeners();
  }

  void addRoomToJoinedRooms(JoinedRoom room) {
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
  JoinedRoom? accessibleRoomWithId(String id) {
    final rooms = accessibleRooms.where((room) => room.id == id);
    return rooms.isNotEmpty ? rooms.first : null;
  }

  OwnedRoom? ownedRoomWithId(String id) {
    final rooms = myRooms.where((room) => room.id == id);
    return rooms.isNotEmpty ? rooms.first : null;
  }

  static AppModel of(BuildContext c, {bool listen = true}) =>
      Provider.of(c, listen: listen);

  void notify() {
    notifyListeners();
  }
}
