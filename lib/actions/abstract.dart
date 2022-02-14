import 'package:shair/services/generator.dart';

abstract class IActionResponse {
  String? id;
}

abstract class IActionRequired {
  final String _id = Generator.uid;
  IActionResponse respond(IActionResponse response) {
    return response..id = _id;
  }
}
