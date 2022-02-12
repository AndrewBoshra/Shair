import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/styled_components/app_bar.dart';
import 'package:shair/styled_components/room_radar.dart';
import 'package:shair/styled_components/spacers.dart';

class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme appTheme = Provider.of(context);
    final textTheme =
        Theme.of(context).textTheme.apply(bodyColor: appTheme.onPrimaryColor);
    return Scaffold(
      appBar: StyledAppBar.transparent(),
      backgroundColor: appTheme.primaryVarColor,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: appTheme.onPrimaryColor),
                ),
                child: const RoomsRadar(),
              ),
            ),
            Spacers.mediumSpacerVr(),
            RichText(
              text: TextSpan(
                style: textTheme.subtitle2,
                children: [
                  const TextSpan(text: 'Or '),
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => RootNavigator.toCreateRoomScreen(pop: true),
                    text: 'Create a room',
                    style: textTheme.subtitle1
                        ?.copyWith(decoration: TextDecoration.underline),
                  ),
                  const TextSpan(text: ' instead'),
                ],
              ),
            ),
            Spacers.mediumSpacerVr(),
          ],
        ),
      ),
    );
  }
}
