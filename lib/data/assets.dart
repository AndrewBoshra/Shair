abstract class ImageAssets {
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
  static String get defaultCharacter => getAllCharacter()[0];
  static const String plus = _imagesPath + '+.png';
  static const String radarLottie = _lottiePath + 'radar.json';
}
