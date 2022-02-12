import 'dart:convert';

import 'package:uuid/uuid.dart';

class DownloadableFile {
  String? url;
  int? size;
}

class Room {
  late String id;
  final String name;
  final bool isLocked;
  String? image;

  List<DownloadableFile> _files = [];

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
}
