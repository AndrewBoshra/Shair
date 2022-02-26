import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

abstract class ImageAssets {
  static Future<Directory> get cachedCharactersDir async {
    final cacheDir = await path_provider.getTemporaryDirectory();
    final characterImagesDir =
        Directory(path.join(cacheDir.path, 'characters'));
    await characterImagesDir.create(recursive: true);
    return characterImagesDir;
  }

  static Future<List<String>> getCachedCharacterImages() async {
    final dir = await cachedCharactersDir;
    final imagePaths = <String>[];
    await for (final image in dir.list()) {
      imagePaths.add(image.path);
    }
    return imagePaths;
  }

  static List<String> getAllCharacter() {
    final imageNames = [
      'm1.jpg',
      'm2.jpg',
      'm3.jpg',
      'g1.jpg',
      'g2.jpg',
      'g3.jpg',
      'g4.jpg',
    ];

    return imageNames.map((e) => _characterPath + e).toList();
  }

  static const _lottiePath = 'assets/lotties/';
  static const _imagesPath = 'assets/images/';
  static const _characterPath = 'assets/characters/';
  static const String welcomeCharacter = _imagesPath + 'lab.png';
  static Future<String> get defaultCharacter async =>
      (await getCachedCharacterImages())[0];
  static const String logo = _imagesPath + 'logo.png';
  static const String radarLottie = _lottiePath + 'radar.json';
}
