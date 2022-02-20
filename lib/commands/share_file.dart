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
    final roomUrl = device.url + '/room/${room.id}/';

    final dFiles = files.map((f) => DownloadableFile.fromBaseUrl(
        baseUrl: roomUrl, name: f.name, size: f.size));

    for (final file in dFiles) {
      ShareFileMessage.fromDownloadableFile(file, room, notifyHost: true)
          .execute();
    }
  }
}
