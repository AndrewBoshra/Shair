import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shair/commands/share_file.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/data/room.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/screens/error.dart';
import 'package:shair/styled_components/avatar.dart';
import 'package:shair/styled_components/room_file_tile.dart';
import 'package:shair/styled_components/spacers.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';

class RoomScreen extends StatelessWidget {
  final String id;
  const RoomScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppModel appModel = Provider.of(context);
    final room = appModel.accessibleRoomWithId(id);
    if (room == null) return const ErrorScreen(error: 'Invalid Room');
    final appTheme = AppTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              height: kToolbarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: RoomAvatar(characterImage: room.roomImage),
              ),
            ),
            Spacers.mediumSpacerHz(),
            Text(room.name)
          ],
        ),
      ),
      backgroundColor: appTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacers.kPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(children: _buildFiles(room)),
            ),
            Spacers.mediumSpacerVr(),
            StyledElevatedButton.primary(
              context,
              onPressed: () => _upload(context, room),
              text: 'Share Files',
            ),
            Spacers.smallSpacerVr(),
          ],
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

  List<Widget> _buildFiles(JoinedRoom room) {
    return room.files
        .map(
          (f) => Padding(
            padding: const EdgeInsets.only(top: Spacers.kPaddingSmall),
            child: SharedFileTile(
              sharedFile: f,
              room: room,
            ),
          ),
        )
        .toList();
  }
}
