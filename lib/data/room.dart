import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:shair/data/config.dart';
import 'package:shair/services/generator.dart';
import 'package:shair/services/network_devices.dart';
import 'package:shair/services/socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RoomUser {
  RoomUser({this.name, this.image, this.code, this.webSocket});
  WebSocketChannel? webSocket;
  String? code;
  String? image;
  String? name;

  @override
  operator ==(Object other) {
    return other is RoomUser && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  Map<String, dynamic> toMap([bool includeCode = false]) {
    return {
      if (includeCode) 'code': code,
      'image': image,
      'name': name,
    };
  }

  factory RoomUser.fromMap(Map<String, dynamic> map) {
    return RoomUser(
      code: map['code'],
      image: map['image'],
      name: map['name'],
    );
  }
  factory RoomUser.formConfig(Config config, {String? code}) {
    return RoomUser(
      code: code,
      image: config.character,
      name: config.name,
    );
  }
}

class DownloadableFile {
  late String url;
  String name;
  int? size;
  late String id;
  String? path;
  RoomUser? owner;
  DownloadableFile({
    required this.id,
    required this.name,
    required this.url,
    required this.owner,
    this.size,
    this.path,
  });

  DownloadableFile.newFile(
      {required this.url,
      required this.name,
      this.size,
      required this.path,
      required this.owner})
      : id = Generator.uid;

  DownloadableFile.fromBaseUrl(
      {required String baseUrl,
      required this.name,
      this.path,
      int? size,
      required this.owner}) {
    id = Generator.uid;
    url = baseUrl + id;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DownloadableFile && other.id == id;
  }

  @override
  int get hashCode => url.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'size': size,
      'id': id,
      'name': name,
      'owner': owner?.toMap(),
    };
  }

  factory DownloadableFile.fromMap(Map<String, dynamic> map) {
    return DownloadableFile(
      url: map['url'],
      size: map['size']?.toInt(),
      id: map['id'],
      name: map['name'],
      owner: map['owner'] != null ? RoomUser.fromMap(map['owner']) : null,
    );
  }
}

class Room {
  late String id;
  final String name;
  final bool isLocked;
  final String? image;

  /// this is null in case this device is the owner of this room
  Device? owner;

  Room({
    String? id,
    required this.name,
    required this.isLocked,
    this.image,
    this.owner,
  }) {
    this.id = id ?? Generator.uid;
  }

  bool get isValid => id.isNotEmpty && name.isNotEmpty;

  Map<String, Object?> toMap([bool includeFiles = false]) {
    return {
      'id': id,
      'name': name,
      'isLocked': isLocked,
      'image': image,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map, {Device? owner}) {
    return Room(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      isLocked: map['isLocked'] == 'true',
      image: map['image'],
      owner: owner,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  bool get isOwned => false;
}

/// a room which is either joined or created by this user.
///
/// the main difference between this class and [Room] is that you can access
/// files and inRoomCode
class JoinedRoom extends Room {
  JoinedRoom({
    required String name,
    required bool isLocked,
    required this.currentUser,
    Device? owner,
    String? id,
    String? image,
    this.webSocket,
  }) : super(
            id: id, image: image, name: name, isLocked: isLocked, owner: owner);

  /// Current Device id in this room.
  Set<DownloadableFile> _files = {};
  WebSocket? webSocket;
  RoomUser currentUser;
  String? get idInRoom => currentUser.code;

  factory JoinedRoom.fromMap(Map<String, dynamic> map, RoomUser currentUser,
      {Device? owner}) {
    final _room = Room.fromMap(map);

    final room = JoinedRoom(
      name: _room.name,
      isLocked: _room.isLocked,
      id: _room.id,
      image: _room.image,
      owner: owner ?? _room.owner,
      currentUser: currentUser,
    );

    final filesRaw = (map['files'] ?? []) as List;
    room._files = filesRaw.map((fr) => DownloadableFile.fromMap(fr)).toSet();
    return room;
  }

  final Set<RoomUser> _participants = {};

  UnmodifiableSetView<RoomUser> get participants =>
      UnmodifiableSetView<RoomUser>(_participants);

  RoomUser? userWithCode(String code) {
    if (!isInRoom(code)) return null;
    return _participants.firstWhere((u) => u.code == code);
  }

  Iterable<DownloadableFile> userFiles(RoomUser user) {
    return files.where((f) => f.owner == user);
  }

  Iterable<DownloadableFile> get myFiles => userFiles(currentUser);

  bool isInRoom(String code) {
    return _participants.any((u) => u.code == code);
  }

  ///add new user to this room with given code
  bool add(String code) {
    return _participants.add(RoomUser(code: code));
  }

  void addFiles(Iterable<DownloadableFile> files) {
    return _files.addAll(files);
  }

  void removeFile(DownloadableFile file) {
    _files.remove(file);
  }

  void sendToHost(SocketMessage message) {
    assert(webSocket != null,
        'trying to send message to host but webSocket is null');
    webSocket!.add(message.toJson());
  }

  ///////////////////////
  //       Getters     //
  ///////////////////////

  UnmodifiableSetView<DownloadableFile> get files =>
      UnmodifiableSetView<DownloadableFile>(_files);
  bool addFile(DownloadableFile file) {
    return _files.add(file);
  }
}

class OwnedRoom extends JoinedRoom {
  OwnedRoom({
    required String name,
    required bool isLocked,
    required RoomUser currentUser,
    Device? owner,
    String? id,
    String? image,
  }) : super(
          name: name,
          isLocked: isLocked,
          id: id,
          image: image,
          owner: owner,
          currentUser: currentUser,
        );

  @override
  bool get isOwned => true;

  bool signWebSocket(String code, WebSocketChannel ws,
      {String? name, String? image}) {
    if (isInRoom(code)) {
      final participant = _participants.firstWhere((p) => p.code == code);
      if (participant.webSocket != null) return false;
      participant.webSocket = ws;
      participant.image = image;
      participant.name = name;
      print('say welcome to $name to our Room');
      return true;
    }
    return false;
  }

  void notifyAll(SocketMessage action) async {
    try {
      for (final participant in _participants) {
        print('will notify ${participant.name} ');
        participant.webSocket?.sink.add(action.toJson());
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
