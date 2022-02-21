import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/app_globals.dart';
import 'package:shair/commands/share_file.dart';
import 'package:shair/data/room.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/screens/error.dart';
import 'package:shair/services/socket.dart';
import 'package:shair/styled_components/app_bar.dart';
import 'package:shair/styled_components/avatar.dart';
import 'package:shair/styled_components/gradient.dart';
import 'package:shair/styled_components/spacers.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';
import 'package:url_launcher/url_launcher.dart';

class RoomScreen extends StatelessWidget {
  final String id;
  const RoomScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppModel appModel = Provider.of(context);
    final room = appModel.accessibleRoomWithId(id);
    if (room == null) return const ErrorScreen(error: 'Invalid Room');
    return GradientBackground(
      child: Scaffold(
        appBar: StyledAppBar.transparent(
          title: Row(
            children: [
              SizedBox(
                height: kToolbarHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: RoomAvatar(imageUrl: room.image),
                ),
              ),
              Spacers.mediumSpacerHz(),
              Text(room.name)
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacers.kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildFiles(room)),
              Spacers.mediumSpacerVr(),
              StyledElevatedButton.onPrimary(
                context,
                onPressed: () => _upload(context, room),
                text: 'Send Files',
              ),
              Spacers.mediumSpacerVr(),
            ],
          ),
        ),
      ),
    );
  }

  void _upload(BuildContext context, JoinedRoom room) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      ShareFilesCommand(
        room,
        result.files,
      ).execute();
    }
  }

  Widget _buildFiles(JoinedRoom room) {
    return ListView(
      children: room.files
          .map((e) => ListTile(
                title: Text(e.url),
                onTap: () async {
                  final file =
                      await AppGlobals.client.downloadFileFormRoom(e, room);
                  print('downloaded ${file?.path}');
                },
              ))
          .toList(),
    );
  }
}
