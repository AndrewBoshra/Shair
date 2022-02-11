// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:shair/data/app_theme.dart';

const _kColorPrimaryVar = Color(0xFF3970ff);
const _kColorPrimary = Color(0xFF55aaff);
const _kColorOnPrimary = Colors.white;

const _kColorSecondary = Color(0xFFf398c4);
const _kColorSecondaryVar = Color(0xFFf9539a);

const _kColorText = Color(0xFF506173);

const _kColorBackground = Color(0xFFfbfaff);
const _kColorOnBackground = Color(0xFF506173);

const _kColorCard = Colors.white;

const _kColorError = Color(0xFFFF0075);
const _kColorOnError = Colors.white;

final AppTheme lightTheme = AppTheme(
  primaryColor: _kColorPrimary,
  primaryVarColor: _kColorPrimaryVar,
  onPrimaryColor: _kColorOnPrimary,
  secondaryColor: _kColorSecondary,
  secondaryVarColor: _kColorSecondaryVar,
  onSecondaryColor: _kColorOnPrimary,
  textColor: _kColorText,
  onPrimaryButtonColor: Colors.white,
  onPrimaryButtonTextColor: _kColorPrimary,
  primaryButtonColor: _kColorPrimary,
  backgroundColor: _kColorBackground,
  onBackgroundColor: _kColorOnBackground,
  cardColor: _kColorCard,
  errorColor: _kColorError,
  onErrorColor: _kColorOnError,
);
