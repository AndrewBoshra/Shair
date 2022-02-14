import 'dart:convert';

import 'package:shair/services/generator.dart';
import 'package:shair/services/network_devices.dart';

class RoomUser {
  String userId;
  RoomUser({
    required this.userId,
  });
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
}

class Room {
  late String id;
  final String name;
  final bool isLocked;
  final String? image;

  /// this is null in case this device is the owner of this room
  final Device? owner;
  List<Device> participants;

  /// Current Device id in this room.
  String? idInRoom;
  final Set<DownloadableFile> _files = {};

  Room({
    String? id,
    required this.name,
    required this.isLocked,
    this.image,
    this.participants = const [],
    this.owner,
  }) {
    this.id = id ?? Generator.uid;
  }
  factory Room.owned({
    String? id,
    required String name,
    required bool isLocked,
    String? image,
  }) =>
      Room(isLocked: isLocked, name: name, id: id, image: image);

  Room.empty()
      : id = '',
        isLocked = true,
        image = null,
        name = '',
        participants = [],
        owner = Device('');

  bool get isValid => id.isNotEmpty && name.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isLocked': isLocked,
      'image': image,
      'device': owner?.toMap(),
      'participants': participants.map((e) => e.toMap()).toList()
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    final participantsRaw = map['participants'] as List;
    final participants = participantsRaw.map((p) => Device.fromMap(p));

    return Room(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      isLocked: map['isLocked'] == 'true',
      image: map['image'],
      participants: participants.toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Room.fromJson(String source) => Room.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  get files => _files;
  void addFile(DownloadableFile file) {
    _files.add(file);
  }

  void removeFile(DownloadableFile file) {
    _files.remove(file);
  }
}
