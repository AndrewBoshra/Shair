import 'package:flutter/material.dart';

class FloatingWidget extends StatefulWidget {
  const FloatingWidget({
    Key? key,
    required this.child,
    this.left = 0,
    this.top = 0,
    required this.duration,
    this.width = 100,
    this.varX = 5,
    this.varY = 10,
    this.height = 100,
    this.offset = 0,
  }) : super(key: key);
  final Widget child;
  final double left;
  final double width;
  final double height;
  final double top;
  final double varX;
  final double varY;
  final double offset;
  final Duration duration;
  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, value: widget.offset);

  late final beginRect = Rect.fromLTWH(widget.left - widget.varX / 2,
      widget.top + widget.varY / 2, widget.width, widget.height);

  late final endRect = Rect.fromLTWH(widget.left + widget.varX / 2,
      widget.top - widget.varY / 2, widget.width, widget.height);

  late final _animation = CurvedAnimation(
      parent: _animationController, curve: Curves.easeInOutSine);
  late final Animation<Rect?> _rectAnimation =
      RectTween(begin: beginRect, end: endRect).animate(_animation);

  @override
  void initState() {
    super.initState();
    _animationController.repeat(period: widget.duration, reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return RelativePositionedTransition(
      child: widget.child,
      rect: _rectAnimation,
      size: size,
    );
  }
}
