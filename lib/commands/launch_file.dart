import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:shair/data/room.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shair/commands/abstract_command.dart';

class LaunchFileCommand extends ICommand {
  final SharedFile sharedFile;
  LaunchFileCommand({
    required this.sharedFile,
  });
  @override
  execute() async {
    final filePath = sharedFile.file.path;
    if (filePath == null) return;
    final Uri uri = Uri.file(filePath);
    final file = File(filePath);
    if (!await file.exists()) return;
    if (Platform.isAndroid || Platform.isIOS) {
      await OpenFile.open(filePath);
    } else if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    }
  }
}
