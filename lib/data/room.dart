import 'dart:convert';

import 'package:shair/services/generator.dart';
import 'package:shair/services/network_devices.dart';

// class RoomUser {
//   String userId;
//   RoomUser({
//     required this.userId,
//   });
// }

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

  Room.empty()
      : id = '',
        isLocked = true,
        image = null,
        name = '',
        owner = Device('');

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

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// a room which is either joined or created by this user.
///
/// the main difference between this class and [Room] is that you can access
/// files and inRoomCode
class JoinedRoom extends Room {
  JoinedRoom({
    required String name,
    required bool isLocked,
    this.participants = const {},
    Device? owner,
    String? id,
    String? image,
  }) : super(
            id: id, image: image, name: name, isLocked: isLocked, owner: owner);

  JoinedRoom.empty()
      : participants = {},
        super.empty();

  Set<Device> participants = {};

  /// Current Device id in this room.
  String? idInRoom;
  Set<DownloadableFile> _files = {};

  factory JoinedRoom.fromMap(Map<String, dynamic> map, {String? idInRoom}) {
    final room = Room.fromMap(map) as JoinedRoom;
    final participantsRaw = (map['participants'] ?? []) as List;
    room.participants =
        participantsRaw.map((map) => Device.fromMap(map)).toSet();
    room.idInRoom = idInRoom;
    final filesRaw = (map['files'] ?? []) as List;
    room._files = filesRaw.map((fr) => DownloadableFile.fromMap(fr)).toSet();
    return room;
  }
  ///////////////////////
  //       Getters     //
  ///////////////////////
  bool get isOwned => owner == null;
  get files => _files;
  void addFile(DownloadableFile file) {
    _files.add(file);
  }

  void removeFile(DownloadableFile file) {
    _files.remove(file);
  }
}
