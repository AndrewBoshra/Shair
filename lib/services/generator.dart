import 'dart:math';

import 'package:uuid/uuid.dart';

const uuid = Uuid();
final random = Random();

abstract class Generator {
  static String get uid => uuid.v4();
  static String get userId => (100000 + random.nextInt(899999)).toString();
}
