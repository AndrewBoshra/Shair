import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:shair/commands/download_file.dart';
import 'package:shair/commands/launch_file.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/data/room.dart';
import 'package:shair/services/downloader.dart';
import 'package:shair/styled_components/avatar.dart';
import 'package:shair/styled_components/spacers.dart';
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

  Widget _buildTileAction(
      AppTheme appTheme, TextTheme textTheme, Widget fileData) {
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
          if (downloader?.state == DownloadState.stopped)
            IconButton(
              onPressed: () => DownloadFileCommand(room, sharedFile).execute(),
              icon: const Icon(Icons.replay_outlined),
            ),
          Flexible(
            fit: FlexFit.tight,
            child: fileData,
          ),
          Text('${downloader?.percentage}%', style: textTheme.caption)
        ],
      ),
    );
  }

  Widget _buildProgressBar(
      AppTheme appTheme, TextTheme textTheme, int progress, Widget fileData) {
    final downloadData = Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacers.kPaddingSmall),
        child: _buildTileAction(appTheme, textTheme, fileData));

    switch (downloader?.state) {
      case DownloadState.finished:
        return _buildFileBase(
          appTheme,
          downloadData,
          color: appTheme.successColor,
        );

      case DownloadState.stopped:
        return _buildFileBase(
          appTheme,
          downloadData,
          color: appTheme.errorColor,
        );
      case DownloadState.paused:
        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (progress > 0)
                  Expanded(
                    child: ColoredBox(color: _barColor(appTheme, progress)!),
                    flex: progress,
                  ),
                if (progress < 100)
                  Expanded(
                    child: ColoredBox(color: appTheme.secondaryVarColor),
                    flex: 100 - progress,
                  ),
              ],
            ),
            downloadData
          ],
        );
      case DownloadState.downloading:
      default:
        return _buildDownloadingAnimation(progress, appTheme, downloadData);
    }
  }

  LiquidLinearProgressIndicator _buildDownloadingAnimation(
      int progress, AppTheme appTheme, Padding downloadData) {
    return LiquidLinearProgressIndicator(
      value: progress / 100,
      valueColor: AlwaysStoppedAnimation(
        _barColor(appTheme, progress)!,
      ),
      backgroundColor: appTheme.secondaryVarColor,
      borderWidth: -100,
      borderColor: Colors.transparent,
      direction: Axis.horizontal,
      center: downloadData,
    );
  }

  Color? _barColor(AppTheme appTheme, int progress) {
    return Color.lerp(
        appTheme.primaryVarColor, appTheme.successColor, progress / 100);
  }

  Widget _buildFileBase(AppTheme appTheme, Widget fileData, {Color? color}) {
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
      child = _buildFileBase(appTheme, fileData);
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
      child: StreamBuilder<DownloadState>(
        stream: downloader?.stateStream,
        builder: (context, snapshot) {
          return child;
        },
      ),
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
