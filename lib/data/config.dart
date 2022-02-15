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

class Config extends Saveable with ChangeNotifier {
  bool _isFirstTime;
  String? _character;
  String? _name;
  ThemeEnum? _theme;

  Config({
    bool isFirstTime = true,
    String? character,
    String? name,
    ThemeEnum? theme,
  })  : _isFirstTime = isFirstTime,
        _character = character,
        _name = name,
        _theme = theme,
        super('config.conf');

  static const String _isFirstTimeStr = 'isFirstTime';
  static const String _characterStr = 'character';
  static const String _nameStr = 'name';
  static const String _themeStr = 'theme';

  bool get isFirstTime => _isFirstTime;
  String? get character => _character;
  String? get name => _name;
  ThemeEnum? get theme => _theme;
  @override
  Map<String, Object?> toMap() {
    return {
      _isFirstTimeStr: _isFirstTime,
      _characterStr: _character,
      _nameStr: _name,
      _themeStr: themeToString(_theme),
    };
  }

  @override
  Config readFromJson(Map<String, Object?> json) {
    _isFirstTime = (json[_isFirstTimeStr] as bool?) ?? true;
    _character = json[_characterStr] as String?;
    _name = json[_nameStr] as String?;
    _theme = themeFromString(json[_nameStr] as String?);
    notifyListeners();
    return this;
  }

  set isFirstTime(bool firstTime) {
    _isFirstTime = firstTime;
    notifyListeners();
  }

  set name(String? newName) {
    _name = newName;
    notifyListeners();
  }

  set character(String? newCharacter) {
    _character = newCharacter;
    notifyListeners();
  }
}
