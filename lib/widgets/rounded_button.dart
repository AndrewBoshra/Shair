import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton(
      {Key? key, required this.onPressed, this.child, this.color, this.padding})
      : super(key: key);
  final VoidCallback onPressed;
  final Widget? child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: child,
      shape: const CircleBorder(),
      color: color ?? Colors.white,
      padding: padding ?? const EdgeInsets.all(kMinInteractiveDimension / 2),
    );
  }
}
