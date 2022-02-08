import 'package:flutter/material.dart';
import 'package:shair/constants/colors.dart';

class StyledElevatedButton extends StatelessWidget {
  const StyledElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      )..copyWith(splashFactory: NoSplash.splashFactory),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
            color: kColorPrimaryVar, fontWeight: FontWeight.bold),
      ),
    );
  }
}
