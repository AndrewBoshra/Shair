import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

Future<void> _createFileIfNotExist(File file) async {
  await file.parent.create(recursive: true);
  if (await file.exists()) return;
  await file.create();
}

class UniversalFile {
  final String name;
  UniversalFile(this.name);

  Future<File> _getFile() async {
    final dataPath = await path_provider.getApplicationDocumentsDirectory();
    final filePath = path.join(dataPath.path, 'Shair', name);
    final file = File(filePath);
    await _createFileIfNotExist(file);
    return file;
  }

  Future<String> read() async {
    final file = await _getFile();
    return file.readAsString();
  }

  Future<Map<String, Object?>> readAsJson() async {
    final fileStr = await read();
    if (fileStr.isEmpty) {
      return {};
    }
    return jsonDecode(fileStr);
  }

  Future<void> write(String str) async {
    final file = await _getFile();
    await file.writeAsString(str, mode: FileMode.writeOnly);
  }

  Future<void> writeJson(Map<String, Object?> json) async {
    final str = jsonEncode(json);
    return write(str);
  }
}

abstract class Saveable {
  Future<Saveable> save() async {
    await file.writeJson(toMap());
    return this;
  }

  Future<Saveable> load() async {
    final json = await file.readAsJson();
    readFromJson(json);
    return this;
  }

  Map<String, Object?> toMap();
  Saveable readFromJson(Map<String, Object?> json);

  late UniversalFile file;

  Saveable(String serializableName) {
    file = UniversalFile(serializableName);
  }
}
