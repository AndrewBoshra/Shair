import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shair/data/room.dart';

enum DownloadState { finished, downloading, stopped, paused }

class Downloader {
  DownloadableFile downloadableFile;
  File? _downloadedFile;

  String downloadPath;
  String? accessCode;
  StreamSubscription? _downloadStreamSubscription;
  int _downloadedSize = 0;
  int _size = -1;
  bool _canceledByUser = false;
  IOSink? _downloadedFileSink;
  DownloadState _state = DownloadState.stopped;
  String? get downloadedFilePath => downloadedFile?.path;

  final StreamController<int> _progressController =
      StreamController<int>.broadcast();
  StreamSink<int> get _progressSink => _progressController.sink;
  Stream<int> get progressStream => _progressController.stream;

  final StreamController<DownloadState> _stateController =
      StreamController<DownloadState>.broadcast();
  StreamSink<DownloadState> get _stateSink => _stateController.sink;
  Stream<DownloadState> get stateStream => _stateController.stream;

  Downloader({
    required this.downloadableFile,
    required this.downloadPath,
    this.accessCode,
    File? downloadedFile,
    int startByte = 0,
  })  : assert(startByte >= 0),
        _downloadedSize = startByte,
        _downloadedFile = downloadedFile;

  int get percentage => (100 * _downloadedSize / _size).round();
  DownloadState get state => _state;
  File? get downloadedFile => _downloadedFile;

  int _parseSize(Map<String, String?> headers) {
    return int.parse(headers['content-length'] ?? '-1');
  }

  String _parseFileName(Map<String, String?> headers) {
    String? disposition = headers['content-disposition'];
    if (disposition == null) return downloadableFile.name;
    final encodedName = disposition.split('filename=').last;
    return utf8.decode(
      encodedName
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .where((c) => c.isNotEmpty)
          .map((e) => int.tryParse(e.trim()) ?? 0)
          .toList(),
    );
  }

  void _updateState(DownloadState state) {
    if (_downloadStreamSubscription == null || state == _state) return;
    _state = state;
    _stateSink.add(state);
  }

  void _handleIncomingData(List<int> data) {
    _downloadedFileSink?.add(data);
    _downloadedSize += data.length;
    _progressSink.add(percentage);
  }

  ///returns a future that completes when the file is downloaded or canceled
  ///or some error happened.
  ///true if success false then this file can't be downloaded
  Future<bool> start() async {
    final req = http.Request('GET', Uri.parse(downloadableFile.url));
    if (accessCode != null) {
      req.headers.addAll({'code': accessCode!});
    }
    req.headers.addAll({'range': 'bytes= $_downloadedSize-'});

    // get file metadata
    final resStream = await req.send();
    if (resStream.statusCode >= 400) {
      return false;
    }

    _size = _parseSize(resStream.headers);
    String fileName = _parseFileName(resStream.headers);

    _downloadedFile = File(path.join(downloadPath, fileName));
    await downloadedFile!.create(recursive: true);
    final stats = await downloadedFile!.stat();

    assert(stats.size == _downloadedSize,
        "trying to download file with wrong start byte");

    _downloadedFileSink =
        downloadedFile!.openWrite(mode: FileMode.writeOnlyAppend);
    // adds the request body parts to the file
    _downloadStreamSubscription = resStream.stream.listen(
      _handleIncomingData,
      onDone: () => _updateState(DownloadState.finished),
      onError: (e) {
        if (percentage == 100) {
          _updateState(DownloadState.finished);
          _progressSink.add(100);
        } else {
          _updateState(DownloadState.stopped);
        }
        debugPrint(e.toString());
      },
    );
    _updateState(DownloadState.downloading);

    await for (final state in stateStream) {
      if (state == DownloadState.finished) {
        break;
      } else if (state == DownloadState.stopped) {
        _downloadedFileSink?.flush();
        break;
      }
    }

    ///no need to flush when the user already canceled it.
    if (!_canceledByUser) {
      await _downloadedFileSink?.flush();
    }
    await _downloadedFileSink?.close();
    return true;
  }

  Future<void> cancel() async {
    _downloadStreamSubscription?.cancel();
    _downloadStreamSubscription = null;
    _canceledByUser = true;
    if (downloadedFile != null && await downloadedFile!.exists()) {
      await _downloadedFileSink?.close();
      await downloadedFile!.delete();
    }
    _downloadedSize = 0;
    _progressSink.add(percentage);

    _updateState(DownloadState.stopped);
  }

  void pause() {
    _downloadStreamSubscription?.pause();
    _updateState(DownloadState.paused);
  }

  void resume() {
    _downloadStreamSubscription?.resume();
    _updateState(DownloadState.downloading);
  }
}
