import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppTheme extends ChangeNotifier {
  Color _primaryColor;

  Color get primaryColor => _primaryColor;

  set primaryColor(Color primaryColor) {
    _primaryColor = primaryColor;
    notifyListeners();
  }

  Color _primaryVarColor;

  Color get primaryVarColor => _primaryVarColor;

  set primaryVarColor(Color primaryVarColor) {
    _primaryVarColor = primaryVarColor;
    notifyListeners();
  }

  Color _onPrimaryColor;

  Color get onPrimaryColor => _onPrimaryColor;

  set onPrimaryColor(Color onPrimaryColor) {
    _onPrimaryColor = onPrimaryColor;
    notifyListeners();
  }

  Color _secondaryColor;

  Color get secondaryColor => _secondaryColor;

  set secondaryColor(Color secondaryColor) {
    _secondaryColor = secondaryColor;
    notifyListeners();
  }

  Color _secondaryVarColor;

  Color get secondaryVarColor => _secondaryVarColor;

  set secondaryVarColor(Color secondaryVarColor) {
    _secondaryVarColor = secondaryVarColor;
    notifyListeners();
  }

  Color _onSecondaryColor;

  Color get onSecondaryColor => _onSecondaryColor;

  set onSecondaryColor(Color onSecondaryColor) {
    _onSecondaryColor = onSecondaryColor;
    notifyListeners();
  }

  Color _textColor;

  Color get textColor => _textColor;

  set textColor(Color textColor) {
    _textColor = textColor;
    notifyListeners();
  }

  Color _onPrimaryButtonColor;

  Color get onPrimaryButtonColor => _onPrimaryButtonColor;

  set onPrimaryButtonColor(Color onPrimaryButtonColor) {
    _onPrimaryButtonColor = onPrimaryButtonColor;
    notifyListeners();
  }

  Color _onPrimaryButtonTextColor;

  Color get onPrimaryButtonTextColor => _onPrimaryButtonTextColor;

  set onPrimaryButtonTextColor(Color onPrimaryButtonTextColor) {
    _onPrimaryButtonTextColor = onPrimaryButtonTextColor;
    notifyListeners();
  }

  Color _primaryButtonColor;
  Color get primaryButtonColor => _primaryButtonColor;

  set primaryButtonColor(Color primaryButtonColor) {
    _primaryButtonColor = primaryButtonColor;
    notifyListeners();
  }

  Color _backgroundColor;

  Color get backgroundColor => _backgroundColor;

  set backgroundColor(Color backgroundColor) {
    _backgroundColor = backgroundColor;
    notifyListeners();
  }

  Color _onBackgroundColor;

  Color get onBackgroundColor => _onBackgroundColor;

  set onBackgroundColor(Color onBackgroundColor) {
    _onBackgroundColor = onBackgroundColor;
    notifyListeners();
  }

  Color _cardColor;

  Color get cardColor => _cardColor;

  set cardColor(Color cardColor) {
    _cardColor = cardColor;
    notifyListeners();
  }

  Color _errorColor;

  Color get errorColor => _errorColor;

  set errorColor(Color errorColor) {
    _errorColor = errorColor;

    notifyListeners();
  }

  Color _onErrorColor;

  Color get onErrorColor => _onErrorColor;

  set onErrorColor(Color onErrorColor) {
    _onErrorColor = onErrorColor;
    notifyListeners();
  }

  Brightness? brightness;

  static AppTheme of(BuildContext c, {bool listen = false}) =>
      Provider.of(c, listen: listen);
  ThemeData get themeData => ThemeData.from(
        colorScheme: ColorScheme(
          brightness: brightness ?? Brightness.light,
          primary: primaryColor,
          onPrimary: onPrimaryColor,
          secondary: secondaryColor,
          onSecondary: onSecondaryColor,
          error: errorColor,
          onError: onErrorColor,
          background: backgroundColor,
          onBackground: onBackgroundColor,
          surface: cardColor,
          onSurface: textColor,
        ),
      );

  AppTheme({
    required Color primaryColor,
    required Color primaryVarColor,
    required Color onPrimaryColor,
    required Color secondaryColor,
    required Color secondaryVarColor,
    required Color onSecondaryColor,
    required Color textColor,
    required Color onPrimaryButtonColor,
    required Color onPrimaryButtonTextColor,
    required Color primaryButtonColor,
    required Color backgroundColor,
    required Color onBackgroundColor,
    required Color cardColor,
    required Color errorColor,
    required Color onErrorColor,
    this.brightness,
  })  : _primaryColor = primaryColor,
        _primaryVarColor = primaryVarColor,
        _onPrimaryColor = onPrimaryColor,
        _secondaryColor = secondaryColor,
        _secondaryVarColor = secondaryVarColor,
        _onSecondaryColor = onSecondaryColor,
        _textColor = textColor,
        _onPrimaryButtonColor = onPrimaryButtonColor,
        _onPrimaryButtonTextColor = onPrimaryButtonTextColor,
        _primaryButtonColor = primaryButtonColor,
        _backgroundColor = backgroundColor,
        _onBackgroundColor = onBackgroundColor,
        _cardColor = cardColor,
        _errorColor = errorColor,
        _onErrorColor = onErrorColor;
}

extension Colorize on TextTheme {
  TextTheme colorize(Color color) =>
      apply(bodyColor: color, decorationColor: color, displayColor: color);
}
