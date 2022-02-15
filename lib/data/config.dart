import 'package:flutter/cupertino.dart';

import 'package:shair/data/saveable.dart';

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
  String? character;
  String? name;

  PersonDetails({this.name, this.character});

  factory PersonDetails.fromMap(Map<String, Object?> map) {
    return PersonDetails(
      name: map[_nameStr].toString(),
      character: map[_characterStr].toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      _characterStr: character,
      _nameStr: name,
    };
  }
}

class Config extends Saveable with ChangeNotifier {
  bool _isFirstTime;
  ThemeEnum? _theme;
  late PersonDetails personDetails;
  Config({
    bool isFirstTime = true,
    String? character,
    String? name,
    ThemeEnum? theme,
  })  : _isFirstTime = isFirstTime,
        _theme = theme,
        super('config.conf') {
    personDetails = PersonDetails(name: name, character: character);
  }

  static const String _isFirstTimeStr = 'isFirstTime';
  static const String _themeStr = 'theme';
  static const String _personStr = 'person';

  bool get isFirstTime => _isFirstTime;
  String? get character => personDetails.character;
  String? get name => personDetails.name;
  ThemeEnum? get theme => _theme;
  @override
  Map<String, Object?> toMap() {
    return {
      _isFirstTimeStr: _isFirstTime,
      _personStr: personDetails.toMap(),
      _themeStr: themeToString(_theme),
    };
  }

  @override
  Config readFromJson(Map<String, Object?> map) {
    _isFirstTime = (map[_isFirstTimeStr] as bool?) ?? true;
    personDetails =
        PersonDetails.fromMap((map[_personStr] as Map<String, Object?>?) ?? {});
    _theme = themeFromString(map[_themeStr] as String?);
    notifyListeners();
    return this;
  }

  set isFirstTime(bool firstTime) {
    _isFirstTime = firstTime;
    notifyListeners();
  }

  set name(String? newName) {
    personDetails.name = newName;
    notifyListeners();
  }

  set character(String? newCharacter) {
    personDetails.character = newCharacter;
    notifyListeners();
  }
}
