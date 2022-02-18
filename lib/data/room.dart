import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:shair/services/generator.dart';
import 'package:shair/services/network_devices.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RoomUser {
  RoomUser({this.code, this.webSocket});
  WebSocketChannel? webSocket;
  String? code;
}

class DownloadableFile {
  late String url;
  int? size;
  late String id;

  DownloadableFile({
    required this.id,
    required this.url,
    this.size,
  });

  DownloadableFile.fromBaseUrl({required String baseUrl, int? size}) {
    id = Generator.uid;
    url = baseUrl + id;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DownloadableFile && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'size': size,
      'id': id,
    };
  }

  factory DownloadableFile.fromMap(Map<String, dynamic> map) {
    return DownloadableFile(
      url: map['url'],
      size: map['size']?.toInt(),
      id: map['id'],
    );
  }

  factory DownloadableFile.fromJson(String source) =>
      DownloadableFile.fromMap(json.decode(source));
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

  Map<String, Object?> toMap() {
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
    Device? owner,
    String? id,
    String? image,
    this.webSocket,
  }) : super(
            id: id, image: image, name: name, isLocked: isLocked, owner: owner);

  /// Current Device id in this room.
  String? idInRoom;
  Set<DownloadableFile> _files = {};
  WebSocket? webSocket;

  factory JoinedRoom.fromMap(Map<String, dynamic> map, {String? idInRoom}) {
    final room = Room.fromMap(map) as JoinedRoom;
    room.idInRoom = idInRoom;
    final filesRaw = (map['files'] ?? []) as List;
    room._files = filesRaw.map((fr) => DownloadableFile.fromMap(fr)).toSet();
    return room;
  }
  ///////////////////////
  //       Getters     //
  ///////////////////////

  get files => _files;
  void addFile(DownloadableFile file) {
    _files.add(file);
  }

  void removeFile(DownloadableFile file) {
    _files.remove(file);
  }
}

class OwnedRoom extends JoinedRoom {
  OwnedRoom({
    required String name,
    required bool isLocked,
    Set<RoomUser> participants = const {},
    Device? owner,
    String? id,
    String? image,
  })  : _participants = participants,
        super(
          name: name,
          isLocked: isLocked,
          id: id,
          image: image,
          owner: owner,
        );

  Set<RoomUser> _participants = {};
  UnmodifiableSetView<RoomUser> get participants =>
      UnmodifiableSetView(_participants);

  @override
  bool get isOwned => true;

  bool isInRoom(String code) {
    return _participants.any((u) => u.code == code);
  }

  ///add new user to this room with given code
  void add(String code) {
    _participants.add(RoomUser(code: code));
  }

  void signWebSocket(String code, WebSocketChannel ws) {
    if (isInRoom(code)) {
      final participant = _participants.firstWhere((p) => p.code == code);
      participant.webSocket = ws;
    }
  }
}
