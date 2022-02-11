import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/data/config.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/styled_components/avatar.dart';
import 'package:shair/styled_components/spacers.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Config config = Provider.of(context);
    final textTheme = Theme.of(context).textTheme;
    AppTheme appTheme = Provider.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: appTheme.secondaryVarColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.elliptical(500, 100),
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      Expanded(
                        child: CharacterAvatar(image: config.character!),
                      ),
                      SelectableText(
                        config.name!,
                        style: textTheme.headlineSmall
                            ?.copyWith(color: appTheme.onSecondaryColor),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: StyledElevatedButton.secondary(
                      context,
                      onPressed: RootNavigator.toJoinRoomScreen,
                      text: 'Join',
                    ),
                  ),
                  Spacers.smallSpacerHz(),
                  Expanded(
                    flex: 2,
                    child: StyledElevatedButton.secondary(
                      context,
                      onPressed: RootNavigator.toCreateRoomScreen,
                      text: 'New Room',
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
