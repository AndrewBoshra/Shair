import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:shair/data/saveable.dart';
import 'package:shair/styled_components/avatar.dart';

enum ThemeEnum { dark, light }
String? themeToString(ThemeEnum? theme) {
  switch (theme) {
    case ThemeEnum.dark:
      return 'dark';
    case ThemeEnum.light:
      return 'light';
    case null:
      return null;
  }
}

ThemeEnum? themeFromString(String? theme) {
  switch (theme) {
    case 'dark':
      return ThemeEnum.dark;
    case 'light':
      return ThemeEnum.light;
  }
  return null;
}

class PersonDetails {
  static const String _characterStr = 'character';
  static const String _nameStr = 'name';
  CharacterImage? character;
  String? name;

  PersonDetails({this.name, this.character});

  factory PersonDetails.fromMap(Map<String, Object?> map,
      {bool isImageLocal = false}) {
    return PersonDetails(
      name: map[_nameStr].toString(),
      character: map[_characterStr] != null
          ? CharacterImage.fromStr(
              uri: map[_characterStr] as String,
              isLocal: isImageLocal,
            )
          : null,
    );
  }

  Map<String, Object?> toMap() {
    return {
      _characterStr: character?.url,
      _nameStr: name,
    };
  }

  PersonDetails copyWith({
    CharacterImage? character,
    String? name,
  }) {
    return PersonDetails(
      character: character ?? this.character,
      name: name ?? this.name,
    );
  }
}

class Config extends Saveable with ChangeNotifier {
  bool _isFirstTime;
  ThemeEnum? _theme;
  String? _defaultDownloadPath;
  late PersonDetails personDetails;
  Config({
    bool isFirstTime = true,
    String? defaultDownloadPath,
    CharacterImage? character,
    String? name,
    ThemeEnum? theme,
  })  : _isFirstTime = isFirstTime,
        _theme = theme,
        _defaultDownloadPath = defaultDownloadPath,
        super('config.conf') {
    personDetails = PersonDetails(name: name, character: character);
  }

  static const String _isFirstTimeStr = 'isFirstTime';
  static const String _themeStr = 'theme';
  static const String _personStr = 'person';
  static const String _downloadPathStr = 'downloadPath';

  bool get isFirstTime => _isFirstTime;
  String? get defaultDownloadPath => _defaultDownloadPath;
  CharacterImage? get character => personDetails.character;
  String? get name => personDetails.name;
  ThemeEnum? get theme => _theme;

  @override
  Map<String, Object?> toMap() {
    return {
      _isFirstTimeStr: _isFirstTime,
      _personStr: personDetails.toMap(),
      _themeStr: themeToString(_theme),
      _downloadPathStr: _defaultDownloadPath,
    };
  }

  @override
  Config readFromMap(Map<String, Object?> map) {
    _isFirstTime = (map[_isFirstTimeStr] as bool?) ?? true;
    _defaultDownloadPath = map[_downloadPathStr] as String?;
    personDetails = PersonDetails.fromMap(
        (map[_personStr] as Map<String, Object?>?) ?? {},
        isImageLocal: true);
    _theme = themeFromString(map[_themeStr] as String?);
    notifyListeners();
    return this;
  }

  Directory? get downloadDir {
    if (_defaultDownloadPath == null) return null;
    return Directory(_defaultDownloadPath!);
  }

  set isFirstTime(bool firstTime) {
    _isFirstTime = firstTime;
    notifyListeners();
  }

  Future<bool> setDefaultDownloadPath(Directory dir) async {
    dir = await dir.create(recursive: true);
    _defaultDownloadPath = dir.path;
    notifyListeners();
    return true;
  }

  set name(String? newName) {
    personDetails.name = newName;
    notifyListeners();
  }

  set character(CharacterImage? newCharacter) {
    personDetails.character = newCharacter;
    notifyListeners();
  }
}
