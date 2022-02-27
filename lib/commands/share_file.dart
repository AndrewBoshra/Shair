import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/services/socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ShareFilesCommand extends ICommand {
  final List<PlatformFile> files;
  final JoinedRoom room;
  ShareFilesCommand(this.room, this.files);
  @override
  execute() async {
    var deviceEither = await wifiDevices.currentDevice;
    deviceEither.fold((f) {
      RootNavigator.toWifiErrorScreen();
    }, (device) {
      final roomUrl = device.url + '/room/${room.id}/files/';

      final dFiles = files.map(
        (f) => DownloadableFile.fromBaseUrl(
          path: f.path,
          baseUrl: roomUrl,
          name: f.name,
          size: f.size,
          owner: room.currentUser,
        ),
      );

      for (final file in dFiles) {
        if (room.myFiles.any((f) => f.file.path == file.path)) {
          return;
        }
        ShareFileMessage.fromDownloadableFile(file, room, notifyHost: true)
            .execute();
      }
    });
  }
}

class ShareFileMessage extends ActionMessage {
  final String fileUrl;
  final String fileId;
  final int? size;
  final String name;
  final String? path;
  final String? fileOwnerCode;

  ShareFileMessage({
    required JoinedRoom room,
    required this.name,
    required this.fileUrl,
    required this.fileId,
    required this.size,
    required this.fileOwnerCode,
    required WebSocketChannel? senderWebSocket,
    this.path,
    bool notifyHost = false,
  }) : super(room, senderWebSocket, notifyHost);

  factory ShareFileMessage.fromDownloadableFile(
    DownloadableFile file,
    JoinedRoom room, {
    WebSocketChannel? webSocket,
    bool notifyHost = false,
  }) {
    return ShareFileMessage(
      room: room,
      fileUrl: file.url,
      fileId: file.id,
      name: file.name,
      size: file.size,
      path: file.path,
      senderWebSocket: webSocket,
      notifyHost: notifyHost,
      fileOwnerCode: file.owner?.code,
    );
  }
  @override
  ownerExecute(OwnedRoom room) {
    // check if this user can send this file
    final canSend =
        room.participants.any((user) => user.webSocket == senderWebSocket);

    if (canSend || senderWebSocket == null) {
      //if this request is from any user or the host himself
      joinedExecute(room);
    }
    room.notifyAll(this);
  }

  @override
  joinedExecute(JoinedRoom room) {
    if (senderWebSocket != null && fileOwnerCode == null) {
      debugPrint('file sender is not in this room');
      return;
    }
    final user = fileOwnerCode != null
        ? room.userWithCode(fileOwnerCode!)
        : room.currentUser;
    room.addFile(
      SharedFile(
        file: DownloadableFile(
          id: fileId,
          name: name,
          url: fileUrl,
          size: size,
          owner: user,
          path: path,
        ),
      ),
    );
  }

  factory ShareFileMessage.fromMap(
      Map<String, dynamic> map, WebSocketChannel? webSocket) {
    final roomId = map['roomId'] as String?;
    final room = ICommand.sAppModel.accessibleRoomWithId(roomId ?? '');
    if (room == null) {
      throw Exception('$roomId is Invalid Room id and was sent to socket');
    }
    return ShareFileMessage(
      room: room,
      fileUrl: map['fileUrl'] ?? '',
      size: map['size']?.toInt() ?? 0,
      senderWebSocket: webSocket,
      fileId: map['fileId'],
      name: map['name'],
      fileOwnerCode: map['fileOwnerCode'],
    );
  }

  @override
  String get actionType => kActionType;
  static const String kActionType = 'send-file';

  @override
  Map<String, dynamic> toMapImpl() {
    return {
      'roomId': room.id,
      'fileUrl': fileUrl,
      'size': size,
      'fileId': fileId,
      'name': name,
      'fileOwnerCode': fileOwnerCode,
    };
  }
}
