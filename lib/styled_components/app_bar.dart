import 'package:flutter/material.dart';

abstract class StyledAppBar {
  static AppBar transparent({Widget? title, Color? foregroundColor}) {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor,
      elevation: 0,
      title: title,
    );
  }
}
