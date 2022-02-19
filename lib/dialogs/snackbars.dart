import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/data/app_theme.dart';

abstract class SnackBars {
  static void show(BuildContext context, SnackBar snackBar) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static SnackBar error(BuildContext context, String text,
      {SnackBarAction? action}) {
    final appTheme = context.read<AppTheme>();
    return SnackBar(
      content: Text(text),
      backgroundColor: appTheme.errorColor,
      action: action,
    );
  }
}
