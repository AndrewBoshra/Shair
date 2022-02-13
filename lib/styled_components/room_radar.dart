import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/data/assets.dart';
import 'package:shair/data/room.dart';
import 'package:shair/models/app_model.dart';

const _kBallRadius = 40.0;
const _kFriction = 6;
const _kVelocity = 1000;
final rand = Random();
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
  Object data;

  double radius;
  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;
  List<Wall> outside(Size size) {
    final walls = <Wall>[];
    if (left < 0) {
      walls.add(Wall.left);
    }
    if (top < 0) {
      walls.add(Wall.top);
    }
    if (right > size.width) {
      walls.add(Wall.right);
    }
    if (bottom > size.height) {
      walls.add(Wall.bottom);
    }
    return walls;
  }

  Ball(this.data, this.x, this.y, this.radius);

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
  }

  bool get isMoving => vel.dx.abs() > 0 && vel.dy.abs() > 0;
  bool isCollidingWith(Ball ball) {
    if (this != ball) {
      //make sure they are different balls
      final distance = magnitude(x - ball.x, y - ball.y);

      if (distance < radius + ball.radius) {
        return true;
      }
    }
    return false;
  }
}

abstract class Collision {
  void resolve(double deltaTime);
}

class BallCollision implements Collision {
  final Ball ball1, ball2;
  BallCollision(this.ball1, this.ball2);
  @override
  void resolve(double deltaTime) {
    final v1 = ball1.vel;
    ball1.vel = ball2.vel;
    ball2.vel = v1;

    ball1.updatePos(deltaTime);
    ball2.updatePos(deltaTime);
  }

  @override
  bool operator ==(Object other) {
    if (other is! BallCollision) {
      return false;
    }
    return (ball1 == other.ball1 && ball2 == other.ball2) ||
        (ball2 == other.ball1 && ball1 == other.ball2);
  }

  @override
  int get hashCode => ball1.hashCode + ball2.hashCode;
}

enum Wall { top, bottom, left, right }

class WallCollision implements Collision {
  final Ball ball;
  final Wall wall;
  WallCollision(this.ball, this.wall);

  @override
  void resolve(double deltaTime) {
    switch (wall) {
      case Wall.top:
      case Wall.bottom:
        ball.vel.dy *= -1;
        break;
      case Wall.left:
      case Wall.right:
        ball.vel.dx *= -1;
        break;
    }
    ball.updatePos(deltaTime);
  }

  @override
  bool operator ==(Object other) {
    if (other is! WallCollision) {
      return false;
    }
    return (ball == other.ball && wall == other.wall);
  }

  @override
  int get hashCode => ball.hashCode + wall.hashCode;
}

class PhysicsSim with ChangeNotifier {
  final List<Ball> _balls = [];
  Size _size = Size.zero;
  Duration lastFrameTime = const Duration();
  Ticker? _ticker;

  void start() => _ticker?.start();

  void removeRoom(Room room) {
    _balls.remove(_balls.firstWhere((ball) => ball.data == room));
  }

  int get _newX =>
      rand.nextInt(_size.width.floor() - 2 * _kBallRadius.floor()) +
      _kBallRadius.floor();

  int get _newY =>
      rand.nextInt(_size.height.floor() - 2 * _kBallRadius.floor()) +
      _kBallRadius.floor();

  void addBall(Object data) {
    int tries = 50;
    late double x;
    late double y;
    while (--tries != 0) {
      x = _newX.toDouble();
      y = _newY.toDouble();
      final isEmpty = isEmptySlot(x, y);
      if (isEmpty) {
        break;
      }
    }
    _balls.add(Ball(data, x, y, _kBallRadius));
  }

  void addBalls(List<Ball> balls) {
    for (final ball in balls) {
      addBall(ball);
    }
  }

  var collisions = <Collision>{};

  void _checkCollision(double deltaTime) {
    final movingBalls = _balls.where((ball) => true);
    for (final movingBall in movingBalls) {
      if (movingBall.left < 0) {
        collisions.add(WallCollision(movingBall, Wall.left));
      }
      if (movingBall.top < 0) {
        collisions.add(WallCollision(movingBall, Wall.top));
      }
      if (movingBall.right > _size.width) {
        collisions.add(WallCollision(movingBall, Wall.right));
      }
      if (movingBall.bottom > _size.height) {
        collisions.add(WallCollision(movingBall, Wall.bottom));
      }
      for (final ball in _balls) {
        if (ball.isCollidingWith(movingBall)) {
          collisions.add(BallCollision(ball, movingBall));
        }
      }
    }
  }

  void _resolveCollisions(double deltaTime) {
    for (final collision in collisions) {
      collision.resolve(deltaTime);
    }
  }

  void _resetOutsideScreen() {
    final staticBalls = _balls.where((ball) => !ball.isMoving);

    for (final ball in staticBalls) {
      final outSideWalls = ball.outside(_size);
      if (outSideWalls.isEmpty) continue;
      ball.x = _newX.toDouble();
      ball.y = _newY.toDouble();
    }
  }

  void update(Duration elapsed) {
    double deltaTime = (elapsed - lastFrameTime).inMicroseconds / 1000000;
    for (final ball in _balls) {
      ball.updatePos(deltaTime);
    }
    collisions = {};
    _checkCollision(deltaTime);
    _resolveCollisions(deltaTime);
    _resetOutsideScreen();
    lastFrameTime = elapsed;
    notifyListeners();
  }

  void _onBallPanUpdate(Ball ball, DragUpdateDetails details) {
    final deltaTime = details.sourceTimeStamp! - ball.lastTimeUpdate!;
    final deltaTimeSeconds = deltaTime.inMicroseconds / 1000000;
    ball.lastTimeUpdate = details.sourceTimeStamp;
    final dx = details.delta.dx / deltaTimeSeconds;
    final dy = details.delta.dy / deltaTimeSeconds;

    final maxSpeed = _size.longestSide;
    ball.vel =
        Vector2.cart(dx.clamp(-maxSpeed, maxSpeed), dy.clamp(-1000, 1000));
  }

  bool isEmptySlot(double x, double y) {
    for (final ball in _balls) {
      if (ball.isCollidingWith(Ball(0, x, y, _kBallRadius))) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }
}

class RoomsRadar extends StatefulWidget {
  const RoomsRadar({Key? key}) : super(key: key);

  @override
  State<RoomsRadar> createState() => _RoomsRadarState();
}

class _RoomsRadarState extends State<RoomsRadar>
    with SingleTickerProviderStateMixin {
  final PhysicsSim _physicsSim = PhysicsSim();
  Set<Room> _rooms = {};

  Widget _buildBall(Ball ball) {
    final room = ball.data as Room;
    return Positioned(
      left: ball.x - ball.radius,
      top: ball.y - ball.radius,
      child: GestureDetector(
        onPanUpdate: (d) => _physicsSim._onBallPanUpdate(ball, d),
        onPanStart: (d) {
          ball.lastTimeUpdate = d.sourceTimeStamp;
        },
        child: SizedBox(
          width: ball.radius * 2,
          height: ball.radius * 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: room.image != null
                    ? NetworkImage(room.image!)
                    : AssetImage(ImageAssets.defaultCharacter) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRooms() {
    AppTheme appTheme = Provider.of(context);
    final widgets = <Widget>[];

    for (final ball in _physicsSim._balls) {
      final room = ball.data as Room;

      widgets.add(_buildBall(ball));
      widgets.add(Positioned(
        child: Text(
          room.name,
          style: TextStyle(color: appTheme.onPrimaryColor),
        ),
        top: ball.y + ball.radius,
        left: ball.x - ball.radius,
      ));
    }
    return widgets;
  }

  void _generateBalls(Set<Room> rooms) {
    final removedRooms = _rooms.difference(rooms);
    //old balls removed from the list after animation controller 1->0
    for (final room in removedRooms) {
      _physicsSim.removeRoom(room);
    }

    final addedRooms = rooms.difference(_rooms);
    //New balls added to the list with animation controller 0->1
    for (final room in addedRooms) {
      _physicsSim.addBall(room);
    }

    _rooms = rooms;
  }

  late AppModel _appModel;
  @override
  void initState() {
    super.initState();
    _appModel = context.read<AppModel>();
    _appModel.pollRooms();
    _appModel.addListener(() {
      _generateBalls(_appModel.rooms);
    });
    _physicsSim._ticker = createTicker(_physicsSim.update);
    _physicsSim.start();
    _physicsSim.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _physicsSim.dispose();
    _appModel.stopPollingRooms();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _physicsSim._size = constraints.biggest;
        return Stack(
          fit: StackFit.expand,
          children: [
            LottieBuilder.asset(ImageAssets.radarLottie),
            ..._buildRooms(),
          ],
        );
      },
    );
  }
}
