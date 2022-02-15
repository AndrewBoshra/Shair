import 'package:flutter/material.dart';
import 'package:shair/actions/actions.dart';
import 'package:shair/dialogs/dialogs.dart';

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
}
