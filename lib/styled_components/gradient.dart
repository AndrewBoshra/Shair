import 'package:flutter/material.dart';
import 'package:shair/constants/colors.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    Key? key,
    this.child,
    this.colors,
    this.stops = const [0.5, 1],
  }) : super(key: key);
  final Widget? child;
  final List<Color>? colors;
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final themecolors = [colorScheme.primaryContainer, colorScheme.primary];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? themecolors,
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          stops: stops,
        ),
      ),
      child: child,
    );
  }
}
