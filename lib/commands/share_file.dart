import 'package:file_picker/file_picker.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';
import 'package:shair/services/socket.dart';

class ShareFilesCommand extends ICommand {
  final List<PlatformFile> files;
  final JoinedRoom room;
  ShareFilesCommand(this.room, this.files);
  @override
  execute() async {
    final device = await wifiDevices.currentDevice;
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
  }
}
