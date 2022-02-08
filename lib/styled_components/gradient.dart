import 'package:flutter/material.dart';
import 'package:shair/constants/colors.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    Key? key,
    this.child,
    this.colors = const [kColorPrimaryVar, kColorPrimary],
    this.stops = const [0.5, 1],
  }) : super(key: key);
  final Widget? child;
  final List<Color> colors;
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          stops: stops,
        ),
      ),
      child: child,
    );
  }
}
