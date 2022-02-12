import 'dart:convert';

import 'package:uuid/uuid.dart';

const _uuid = Uuid();

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
    id = _uuid.v4();
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
  String? image;

  final Set<DownloadableFile> _files = {};

  Room({
    String? id,
    required this.name,
    required this.isLocked,
    this.image,
  }) {
    this.id = id ?? const Uuid().v4();
  }
  Room.empty()
      : id = '',
        isLocked = true,
        name = '';
  bool get isValid => id.isNotEmpty && name.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isLocked': isLocked,
      'image': image,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      isLocked: map['isLocked'] == 'true',
      image: map['image'],
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
}

class OwnedRoom extends Room {
  OwnedRoom.empty() : super.empty();

  OwnedRoom({required String name, required bool isLocked})
      : super(name: name, isLocked: isLocked);

  void addFile(DownloadableFile file) {
    _files.add(file);
  }

  void removeFile(DownloadableFile file) {
    _files.remove(file);
  }
}
