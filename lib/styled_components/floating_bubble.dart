import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shair/constants/colors.dart';
import 'package:shair/widgets/floating_widget.dart';

const _kCircleAnimationDuration = Duration(milliseconds: 3600);

/// Need TO be inside [Stack] in order for it to work
///
class FloatingBubble extends StatelessWidget {
  const FloatingBubble({
    Key? key,
    required this.left,
    required this.top,
    this.dim = 150,
    this.varX = 10,
    this.varY = 20,
    this.duration = _kCircleAnimationDuration,
    this.color = kColorPrimary,
  }) : super(key: key);
  final double left;
  final double dim;
  final double top;
  final double varX;
  final double varY;
  final Duration duration;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return FloatingWidget(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
      left: left,
      width: dim,
      height: dim,
      top: top,
      varX: varX,
      varY: varY,
      offset: Random().nextDouble(),
      duration: duration,
    );
  }
}
