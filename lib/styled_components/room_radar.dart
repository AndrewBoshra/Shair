import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shair/data/room.dart';
import 'package:shair/models/app_model.dart';

const _kBallRadius = 40.0;
const _kFriction = 0;
double magnitude(num dx, num dy) {
  return sqrt(pow(dy, 2) + pow(dx, 2));
}

class Vector2 {
  double dy = 0;
  double dx = 0;

  set mag(double newMag) {
    dx = newMag * cos(angle);
    dy = newMag * sin(angle);
  }

  double get angle => atan2(dy, dx);
  double get mag => magnitude(dx, dy);
  Vector2.cart(this.dx, this.dy);
}

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

  Function(Ball ball, DragUpdateDetails details)? onPanUpdate;
  Ball(this.x, this.y, this.radius, this._widget, {this.onPanUpdate});

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

  bool get isMoving => vel.dx > 0 && vel.dy > 0;
  Widget get widget => Positioned(
        child: GestureDetector(
          onPanUpdate: (d) => onPanUpdate?.call(this, d),
          onPanStart: (d) {
            lastTimeUpdate = d.sourceTimeStamp;
          },
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: _widget,
          ),
        ),
        left: x - radius,
        top: y - radius,
      );
}

class Collision {
  final Ball ball1, ball2;
  Collision(this.ball1, this.ball2);

  void resolve() {
    final v1 = ball1.vel;
    ball1.vel = ball2.vel;
    ball2.vel = v1;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Collision) {
      return false;
    }
    return (ball1 == other.ball1 && ball2 == other.ball2) ||
        (ball2 == other.ball1 && ball1 == other.ball2);
  }

  @override
  int get hashCode => ball1.hashCode + ball2.hashCode;
}

class PhysicsSim with ChangeNotifier {
  List<Ball> _balls = [];
  Size _size = Size.zero;
  Duration lastFrameTime = Duration();
  Ticker? _ticker;

  void start() => _ticker?.start();

  void addBall(Ball ball) {
    if (_balls.contains(ball)) return;
    ball.onPanUpdate = _onBallPanUpdate;
    _balls.add(ball);
  }

  void addBalls(List<Ball> balls) {
    for (final ball in balls) {
      addBall(ball);
    }
  }

  void _checkCollision(double deltaTime) {
    final movingBalls = _balls.where((ball) => true);
    final collisions = <Collision>{};

    for (final movingBall in movingBalls) {
      for (final ball in _balls) {
        if (ball != movingBall) {
          //make sure they are different balls
          final distance =
              magnitude(ball.x - movingBall.x, ball.y - movingBall.y);

          if (distance < ball.radius + movingBall.radius) {
            collisions.add(Collision(ball, movingBall));
          }
        }
      }
    }
    print(collisions.length);
    // for (final ball in collidedBalls) {
    //   ball.updatePos(deltaTime);
    // }
  }

  void update(Duration elapsed) {
    double deltaTime = (elapsed - lastFrameTime).inMicroseconds / 1000000;
    for (final ball in _balls) {
      ball.updatePos(deltaTime);
    }
    _checkCollision(deltaTime);
    lastFrameTime = elapsed;
    notifyListeners();
  }

  void _onBallPanUpdate(Ball ball, DragUpdateDetails details) {
    final deltaTime = details.sourceTimeStamp! - ball.lastTimeUpdate!;
    final deltaTimeSeconds = deltaTime.inMicroseconds / 1000000;
    ball.lastTimeUpdate = details.sourceTimeStamp;

    ball.vel = Vector2.cart(details.delta.dx / deltaTimeSeconds,
        details.delta.dy / deltaTimeSeconds);
  }
}

class RoomsRadar extends StatefulWidget {
  const RoomsRadar({Key? key, required this.rooms}) : super(key: key);
  final List<Room> rooms;

  @override
  State<RoomsRadar> createState() => _RoomsRadarState();
}

class _RoomsRadarState extends State<RoomsRadar>
    with SingleTickerProviderStateMixin {
  final PhysicsSim _physicsSim = PhysicsSim();

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
    return _physicsSim._balls
        .map(
          (e) => e.widget,
        )
        .toList();
  }

  void _generateBalls(rooms) {
    double x = 0;
    double y = 0;

    for (final room in rooms) {
      final ball = Ball(x, y, _kBallRadius, _buildRoom(room));
      _physicsSim.addBall(ball);
      x += _kBallRadius * 2 + 20;
      y += _kBallRadius * 2 + 20;
    }
    _physicsSim._ticker = createTicker(_physicsSim.update);
    _physicsSim.start();
    _physicsSim.addListener(() => setState(() {}));
  }

  @override
  void initState() {
    context.read<AppModel>().rooms.then(_generateBalls);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent.shade100,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _physicsSim._size = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            fit: StackFit.expand,
            children: _buildRooms(),
          );
        },
      ),
    );
  }
}
