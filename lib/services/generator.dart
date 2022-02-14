import 'dart:math';

import 'package:uuid/uuid.dart';

const uuid = Uuid();
final random = Random();

abstract class Generator {
  static String get uid => uuid.v4();
  static String get userId {
    final num1 = (100 + random.nextInt(899)).toString();
    final num2 = (100 + random.nextInt(899)).toString();
    return '$num1-$num2';
  }
}
