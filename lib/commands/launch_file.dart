import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:mime/mime.dart';
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
    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.file(filePath).toString(),
        type: lookupMimeType(filePath),
      );
      await intent.launch();
    } else if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    }
  }
}
