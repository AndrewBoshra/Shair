import 'dart:async';

import 'package:shair/actions/abstract.dart';
import 'package:shair/data/config.dart';
import 'package:shair/data/room.dart';
import 'package:shair/dialogs/show_dialog.dart';
import 'package:shair/root_nav.dart';

class JoinRequest extends IActionRequired {
  final Room room;
  final PersonDetails personDetails;
  final String code;

  JoinRequest({
    required this.personDetails,
    required this.code,
    required this.room,
  });
  @override
  FutureOr<JoinResponse> respond() async {
    bool? accepted =
        await Dialogs.showJoinRequestDialog(RootNavigator.nav!.context, this);
    return JoinResponse(accepted ?? false);
  }
}

class JoinResponse extends IActionResponse {
  final bool isAccepted;
  JoinResponse(this.isAccepted);
}
