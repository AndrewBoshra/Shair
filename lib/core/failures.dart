import 'dart:math';

class Failure {
  final String message;
  final Object? error;
  Failure(this.message, [this.error]);
}

class HotSpotHostWifiFailure extends Failure {
  HotSpotHostWifiFailure(
      [String message = 'HotSpot Owner can\'t join to a room ', error])
      : super(message, error);
}
