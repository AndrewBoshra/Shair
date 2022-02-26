import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shair/commands/download_file.dart';
import 'package:shair/commands/launch_file.dart';

import 'package:shair/commands/share_file.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/data/room.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/screens/error.dart';
import 'package:shair/services/downloader.dart';
import 'package:shair/styled_components/app_bar.dart';
import 'package:shair/styled_components/avatar.dart';
import 'package:shair/styled_components/gradient.dart';
import 'package:shair/styled_components/spacers.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';
import 'package:shair/utils/extensions.dart';

const _kBorderRadius = 20.0;
const _r = Radius.circular(_kBorderRadius);
const _kSenderBorder =
    BorderRadius.only(bottomLeft: _r, topLeft: _r, topRight: _r);

class SharedFileTile extends StatelessWidget {
  const SharedFileTile({Key? key, required this.sharedFile, required this.room})
      : super(key: key);
  final SharedFile sharedFile;
  final JoinedRoom room;

  DownloadableFile get file => sharedFile.file;
  Downloader? get downloader => sharedFile.downloader;

  Widget _buildFileData(TextTheme textTheme) {
    return Text(
      file.name,
      style: textTheme.subtitle2,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressBar(
      AppTheme appTheme, TextTheme textTheme, int progress, Widget fileData) {
    final downloadData = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacers.kPaddingSmall),
      child: StreamBuilder<DownloadState>(
          stream: downloader?.stateStream,
          builder: (context, snapshot) {
            return IconTheme(
              data: IconThemeData(color: appTheme.onSecondaryColor),
              child: Row(
                children: [
                  if (downloader?.state == DownloadState.paused)
                    IconButton(
                      onPressed: downloader?.resume,
                      icon: const Icon(Icons.play_arrow_rounded),
                    ),
                  if (downloader?.state == DownloadState.downloading)
                    IconButton(
                      onPressed: downloader?.pause,
                      icon: const Icon(Icons.pause),
                    ),
                  if (downloader?.state == DownloadState.finished)
                    IconButton(
                      onPressed: () => LaunchFileCommand(
                        sharedFile: sharedFile,
                      ).execute(),
                      icon: const Icon(Icons.folder_open_rounded),
                    ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: fileData,
                  ),
                  Text('$progress%', style: textTheme.caption)
                ],
              ),
            );
          }),
    );
    if (downloader?.state == DownloadState.finished) {
      return _buildOwnedFile(
        appTheme,
        downloadData,
        color: appTheme.successColor,
      );
    }
    return LiquidLinearProgressIndicator(
      value: progress / 100, // Defaults to 0.5.
      valueColor: AlwaysStoppedAnimation(
        Color.lerp(
            appTheme.primaryVarColor, appTheme.successColor, progress / 100)!,
      ),
      backgroundColor: appTheme.secondaryVarColor,
      borderWidth: -100,
      borderColor: Colors.transparent,
      direction: Axis.horizontal,
      center: downloadData,
    );
  }

  Widget _buildOwnedFile(AppTheme appTheme, Widget fileData, {Color? color}) {
    return ColoredBox(
      color: color ?? appTheme.primaryVarColor,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(
            left: Spacers.kPadding,
          ),
          child: fileData,
        ),
      ),
    );
  }

  Widget _buildFile(AppTheme appTheme, Widget fileData) {
    return ColoredBox(
      color: appTheme.secondaryVarColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacers.kPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: fileData),
            IconButton(
              icon: Icon(Icons.download, color: appTheme.onSecondaryColor),
              onPressed: () {
                DownloadFileCommand(room, sharedFile).execute();
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final textTheme =
        Theme.of(context).textTheme.colorize(appTheme.onSecondaryColor);
    final isOwned = room.isMine(sharedFile);
    late Widget child;
    final fileData = _buildFileData(textTheme);

    if (isOwned) {
      child = _buildOwnedFile(appTheme, fileData);
    } else if (!sharedFile.isDownloading) {
      child = _buildFile(appTheme, fileData);
    } else {
      child = StreamBuilder<int>(
        initialData: 0,
        stream: downloader!.progressStream,
        builder: (context, snapshot) {
          return _buildProgressBar(
              appTheme, textTheme, snapshot.data!, fileData);
        },
      );
    }

    child = ClipRRect(
      borderRadius: isOwned ? _kSenderBorder : _kSenderBorder.flipped(),
      child: child,
    );

    final ownerData = [
      Text(
        file.owner?.name ?? '',
        style: textTheme.caption?.copyWith(color: appTheme.onBackgroundColor),
      ),
      const SizedBox(width: 2),
      RoomAvatar(
          characterImage: file.owner?.userImage, radius: _kBorderRadius / 2)
    ];
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: child,
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment:
              isOwned ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: isOwned ? ownerData : ownerData.reversed.toList(),
        )
      ],
    );
  }
}

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
