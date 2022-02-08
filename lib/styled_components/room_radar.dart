import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shair/data/room.dart';
import 'package:shair/models/app_model.dart';

const _kBallRadius = 80.0;
const _kFriction = 5.0;

class Vector2 {
  double dy = 0;
  double dx = 0;

  set mag(double newMag) {
    dx = newMag * cos(angle);
    dy = newMag * sin(angle);
  }

  double get angle => atan2(dy, dx);
  double get mag => sqrt(pow(dy, 2) + pow(dx, 2));
  Vector2.cart(this.dx, this.dy);
}

// class PhysicsSim {
//   List<Ball> _balls = [];
//   Size _canavasSize = Size.zero;

//   final double _friction;

//   PhysicsSim({double friction = _kFriction}) : _friction = friction;

//   void update(double deltaTime) {
//   }
// }

class Ball {
  /// Center X
  double x;

  /// Center Y
  double y;

  Duration? lastTimeUpdate;

  /// pixels per second
  Vector2 vel = Vector2.cart(0, 0);

  double radius;

  final Widget _widget;

  final Function(Ball ball, DragUpdateDetails details) onPanUpdate;
  Ball(
    this.x,
    this.y,
    this.radius,
    this._widget,
    this.onPanUpdate,
  );

  void updatePos(double seconds) {
    x += vel.dx * seconds;
    y += vel.dy * seconds;

    final velMag = vel.mag;
    if (velMag < _kFriction) {
      vel.dx = 0;
      vel.dy = 0;
    } else {
      vel.mag = velMag - _kFriction;
    }

    if (vel.dy.abs() < _kFriction) {
      vel.dy = 0;
    } else {
      vel.dy -= vel.dy.isNegative ? -_kFriction : _kFriction;
    }
  }

  Widget get widget => Positioned(
        child: GestureDetector(
          onPanUpdate: (d) => onPanUpdate(this, d),
          onPanStart: (d) {
            lastTimeUpdate = d.sourceTimeStamp;
          },
          child: SizedBox(
            width: radius,
            height: radius,
            child: _widget,
          ),
        ),
        left: x - radius / 2,
        top: y - radius / 2,
      );
}

class RoomsRadar extends StatefulWidget {
  const RoomsRadar({Key? key, required this.rooms}) : super(key: key);
  final List<Room> rooms;

  @override
  State<RoomsRadar> createState() => _RoomsRadarState();
}

class _RoomsRadarState extends State<RoomsRadar>
    with SingleTickerProviderStateMixin {
  late Size _size;
  List<Ball> _balls = [];
  Duration lastFrameTime = const Duration();

  Widget _buildRoom(Room room) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage(room.image),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  List<Widget> _buildRooms() {
    return _balls
        .map(
          (e) => e.widget,
        )
        .toList();
    // return rooms.map((e) => RoomWidget(room: e)).toList();
  }

  void _onPanUpdate(Ball ball, DragUpdateDetails details) {
    final deltaTime = details.sourceTimeStamp! - ball.lastTimeUpdate!;
    final deltaTimeSeconds = deltaTime.inMicroseconds / 1000000;
    ball.lastTimeUpdate = details.sourceTimeStamp;

    ball.vel = Vector2.cart(details.delta.dx / deltaTimeSeconds,
        details.delta.dy / deltaTimeSeconds);
  }

  void _updateFrame(Duration elapsed) {
    double deltaTime = (elapsed - lastFrameTime).inMicroseconds / 1000000;
    for (final ball in _balls) {
      ball.updatePos(deltaTime);
    }
    lastFrameTime = elapsed;
    setState(() {});
  }

  late Ticker _ticker;
  @override
  void initState() {
    context.read<AppModel>().rooms.then((rooms) {
      double x = 0;
      double y = 0;
      final balls = <Ball>[];

      for (final room in rooms) {
        balls.add(Ball(x, y, _kBallRadius, _buildRoom(room), _onPanUpdate));
        x += _kBallRadius + 20;
        y += _kBallRadius + 20;
      }
      _ticker = createTicker(_updateFrame);
      setState(() {
        _balls = balls;
        _ticker.start();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent.shade100,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _size = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            fit: StackFit.expand,
            children: _buildRooms(),
          );
        },
      ),
    );
  }
}
