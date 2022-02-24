import 'dart:async';
import 'dart:io';

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
  int downloadedSize = 0;
  int _size = -1;
  bool _canceledByUser = false;
  IOSink? _downloadedFileSink;
  DownloadState _state = DownloadState.stopped;

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
        downloadedSize = startByte,
        _downloadedFile = downloadedFile;

  int get percentage => (100 * downloadedSize / _size).round();
  DownloadState get state => _state;
  File? get downloadedFile => _downloadedFile;

  int _parseSize(Map<String, String?> headers) {
    return int.parse(headers['content-length'] ?? '-1');
  }

  String _parseFileName(Map<String, String?> headers) {
    String? disposition = headers['content-disposition'];
    if (disposition == null) return downloadableFile.name;
    return disposition.split('filename=').last;
  }

  void _updateState(DownloadState state) {
    if (_downloadStreamSubscription == null || state == _state) return;
    _state = state;
    _stateSink.add(state);
  }

  void _handleIncomingData(List<int> data) {
    _downloadedFileSink?.add(data);
    downloadedSize += data.length;
    _progressSink.add(percentage);
  }

  ///returns a future that completes when the file is downloaded or canceled
  ///or some error happened.
  Future<void> start() async {
    final req = http.Request('GET', Uri.parse(downloadableFile.url));
    if (accessCode != null) {
      req.headers.addAll({'code': accessCode!});
    }
    req.headers.addAll({'range': 'bytes= $downloadedSize-'});

    // get file metadata
    final resStream = await req.send();
    _size = _parseSize(resStream.headers);
    String fileName = _parseFileName(resStream.headers);

    _downloadedFile = File(path.join(downloadPath, fileName));
    await downloadedFile!.create(recursive: true);
    final stats = await downloadedFile!.stat();

    assert(stats.size == downloadedSize,
        "trying to download file with wrong start byte");

    _downloadedFileSink =
        downloadedFile!.openWrite(mode: FileMode.writeOnlyAppend);
    // adds the request body parts to the file
    _downloadStreamSubscription = resStream.stream.listen(
      _handleIncomingData,
      onDone: () => _updateState(DownloadState.finished),
    );

    _updateState(DownloadState.downloading);
    await _downloadStreamSubscription!.asFuture();

    ///no need to flush when the user already canceled it.
    if (!_canceledByUser) {
      await _downloadedFileSink?.flush();
    }
    await _downloadedFileSink?.close();
  }

  Future<void> cancel() async {
    _downloadStreamSubscription?.cancel();
    _downloadStreamSubscription = null;
    _canceledByUser = true;
    if (downloadedFile != null && await downloadedFile!.exists()) {
      await _downloadedFileSink?.close();
      await downloadedFile!.delete();
    }
    downloadedSize = 0;
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
