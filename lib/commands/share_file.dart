import 'package:file_picker/file_picker.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';

class ShareFileCommand extends ICommand {
  ShareFileCommand(BuildContext context, this.file, this.room)
      : super(context: context);
  final PlatformFile file;
  final Room room;

  @override
  execute() {
    // TODO: implement execute
    throw UnimplementedError();
  }
}
