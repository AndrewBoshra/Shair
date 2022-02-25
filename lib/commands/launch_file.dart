import 'dart:io';

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
    if (await File(filePath).exists()) {
      if (!await launch(uri.toString())) {
        print('Could not launch $uri');
      }
    }
  }
}
