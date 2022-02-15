import 'package:flutter/material.dart';

import 'package:shair/data/app_theme.dart';

abstract class StyledElevatedButton {
  static Widget onPrimary(
    BuildContext context, {
    required VoidCallback onPressed,
    required String text,
  }) {
    final appTheme = AppTheme.of(context);

    return _StyledElevatedButton(
      onPressed: onPressed,
      text: text,
      textColor: appTheme.onPrimaryButtonTextColor,
      color: appTheme.onPrimaryButtonColor,
    );
  }

  static Widget primary(
    BuildContext context, {
    required VoidCallback onPressed,
    required String text,
  }) {
    final appTheme = AppTheme.of(context);

    return _StyledElevatedButton(
      onPressed: onPressed,
      text: text,
      textColor: appTheme.onPrimaryButtonColor,
      color: appTheme.onPrimaryButtonTextColor,
    );
  }

  static Widget secondary(
    BuildContext context, {
    required VoidCallback onPressed,
    required String text,
  }) {
    final appTheme = AppTheme.of(context);

    return _StyledElevatedButton(
      onPressed: onPressed,
      text: text,
      textColor: appTheme.onSecondaryColor,
      color: appTheme.secondaryVarColor,
    );
  }

  static Widget error(
    BuildContext context, {
    required VoidCallback onPressed,
    required String text,
  }) {
    final appTheme = AppTheme.of(context);

    return _StyledElevatedButton(
      onPressed: onPressed,
      text: text,
      textColor: appTheme.onErrorColor,
      color: appTheme.errorColor,
    );
  }
}

class _StyledElevatedButton extends StatelessWidget {
  const _StyledElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.textColor,
    required this.color,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final Color textColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      )..copyWith(splashFactory: NoSplash.splashFactory),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
