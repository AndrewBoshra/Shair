import 'package:flutter/material.dart';
import 'package:shair/dialogs/dialogs.dart';

abstract class Dialogs {
  static show(BuildContext context, Widget dialog, {NavigatorState? nav}) {
    final _nav = nav ?? Navigator.of(context);
    _nav.push(DialogRoute(context: context, builder: (c) => dialog));
  }

  static showJoinCodeDialog(BuildContext context, String code) =>
      show(context, JoinCodeDialog(code: code));
}
