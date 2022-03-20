import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shair/actions/actions.dart';
import 'package:shair/data/room.dart';
import 'package:shair/dialogs/dialogs.dart';
import 'package:shair/services/server.dart';

abstract class Dialogs {
  static Future<T?> show<T>(BuildContext context, Widget dialog,
      {NavigatorState? nav}) {
    final _nav = nav ?? Navigator.of(context);
    return _nav.push(DialogRoute(context: context, builder: (c) => dialog));
  }

  static Future<T?> showJoinCodeDialog<T>(BuildContext context, String code) =>
      show(context, JoinCodeDialog(code: code));

  static Future showJoinRequestDialog(
          BuildContext context, JoinRequest request) =>
      show(context, JoinRequestDialog(request: request));

  static Future showRoomQr(BuildContext context, OwnedRoom room) => show(
      context,
      QRCodeDialog(data: RestServer.roomUrl(room, room.generateUser())));
}
