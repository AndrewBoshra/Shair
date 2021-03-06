import 'dart:async';
import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shair/actions/abstract.dart';
import 'package:shair/commands/room_polling.dart';
import 'package:shair/core/failures.dart';
import 'package:shair/data/room.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

///class Containing general app state
///
class AppModel extends ChangeNotifier {
  Either<Failure, Set<Room>> _availableRooms = right({});
  final Set<OwnedRoom> _myRooms = {};
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
  Either<Failure, UnmodifiableSetView<Room>> get availableRooms =>
      _availableRooms.fold(left, (r) => right(UnmodifiableSetView(r)));

  UnmodifiableSetView<OwnedRoom> get myRooms => UnmodifiableSetView(_myRooms);

  UnmodifiableSetView<JoinedRoom> get joinedRooms =>
      UnmodifiableSetView(_joinedRooms);

  Set<JoinedRoom> get accessibleRooms => {...joinedRooms, ..._myRooms};

  set availableRooms(Either<Failure, Set<Room>> rooms) {
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

  void removeFromJoinedRooms(JoinedRoom room) {
    _joinedRooms.remove(room);
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

  List<JoinedRoom> joinedRoomWithWebSocket(WebSocketChannel ws) {
    return accessibleRooms
        .where((room) => room.userWithWebSocket(ws) != null)
        .toList();
  }

  static AppModel of(BuildContext c, {bool listen = true}) =>
      Provider.of(c, listen: listen);

  void notify() {
    notifyListeners();
  }
}
