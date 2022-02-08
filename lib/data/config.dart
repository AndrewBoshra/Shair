import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shair/data/saveable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config extends Saveable with ChangeNotifier {
  bool _isFirstTime;
  String? _character;
  String? _name;

  Config({
    bool isFirstTime = true,
    String? character,
    String? name,
  })  : _isFirstTime = isFirstTime,
        _character = character,
        _name = name,
        super('config.conf');

  static const String _isFirstTimeStr = 'isFirstTime';
  static const String _characterStr = 'character';
  static const String _nameStr = 'name';

  bool get isFirstTime => _isFirstTime;
  String? get character => _character;
  String? get name => _name;
  @override
  Map<String, Object?> toJson() {
    return {
      _isFirstTimeStr: _isFirstTime,
      _characterStr: _character,
      _nameStr: _name,
    };
  }

  @override
  Config readFromJson(Map<String, Object?> json) {
    _isFirstTime = (json[_isFirstTimeStr] as bool?) ?? true;
    _character = json[_characterStr] as String?;
    _name = json[_nameStr] as String?;
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
