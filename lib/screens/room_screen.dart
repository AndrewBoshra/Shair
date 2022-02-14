import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/commands/share_file.dart';
import 'package:shair/data/room.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/screens/error.dart';
import 'package:shair/styled_components/app_bar.dart';
import 'package:shair/styled_components/avatar.dart';
import 'package:shair/styled_components/gradient.dart';
import 'package:shair/styled_components/spacers.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';

class RoomScreen extends StatelessWidget {
  final String id;
  const RoomScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppModel appModel = Provider.of(context);
    final room = appModel.accessableRoowmWithId(id);
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
                  child: RoomAvatar(room: room),
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

  void _upload(BuildContext context, Room room) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      for (final file in result.files) {
        ShareFileCommand(context, file, room).execute();
      }
    }
  }

  Widget _buildFiles(Room room) {
    return ListView();
  }
}
