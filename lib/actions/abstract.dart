import 'dart:async';

import 'package:shair/commands/abstract_command.dart';
import 'package:shair/services/generator.dart';
import 'package:shelf/shelf.dart';

abstract class IActionResponse {
  String? id;
}

abstract class IActionRequired with ICommand {
  final String id = Generator.uid;

  FutureOr<IActionResponse> respond();

  @override
  execute() async {
    final response = await respond();
    response.id = id;
    appModel.responseSink.add(response);
  }
}
