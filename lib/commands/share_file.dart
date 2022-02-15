import 'package:file_picker/file_picker.dart';
import 'package:shair/commands/abstract_command.dart';
import 'package:shair/data/room.dart';

class ShareFileCommand extends ICommand {
  ShareFileCommand(this.file, this.room);

  final PlatformFile file;
  final Room room;

  @override
  execute() {
    // TODO: implement execute
    throw UnimplementedError();
  }
}
