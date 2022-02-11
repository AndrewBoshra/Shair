import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/data/app_theme.dart';

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
    AppTheme appTheme = Provider.of(context);

    final themecolors = [appTheme.primaryVarColor, appTheme.primaryColor];
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
