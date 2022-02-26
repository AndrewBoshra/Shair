import 'dart:io';

import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';
import 'package:shair/services/downloader.dart';
import 'package:path/path.dart' as path;

class DownloadFileCommand extends ICommand {
  final JoinedRoom room;
  final SharedFile sharedFile;
  DownloadFileCommand(this.room, this.sharedFile);

  @override
  execute() async {
    assert(room.containsFile(sharedFile));
    assert(!room.isMine(sharedFile));
    final downloadPath = config.downloadDir!.path;
    final filePath = path.join(downloadPath, sharedFile.file.name);
    //cancel if was already downloading
    await sharedFile.downloader?.cancel();

    final file = File(filePath);
    final stat = await file.stat();
    sharedFile.downloader = Downloader(
      downloadableFile: sharedFile.file,
      downloadPath: downloadPath,
      startByte: stat.size.clamp(0, double.infinity).toInt(),
      accessCode: room.idInRoom,
    );

    final downloader = sharedFile.downloader;
    appModel.notify();
    final success = await downloader?.start();
    if (success != true) {
      sharedFile.downloader = null;
      appModel.notify();
    }
    if (downloader?.state == DownloadState.finished) {
      sharedFile.file.path = downloader?.downloadedFilePath;
    }
  }
}
