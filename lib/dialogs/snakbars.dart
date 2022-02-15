import 'package:flutter/material.dart';
import 'package:shair/data/app_theme.dart';

abstract class SnackBars {
  static void show(BuildContext context, SnackBar snackBar) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static SnackBar error(BuildContext context, String text,
      {SnackBarAction? action}) {
    final appTheme = AppTheme.of(context, listen: false);
    return SnackBar(
      content: Text(text),
      backgroundColor: appTheme.errorColor,
      action: action,
    );
  }
}
