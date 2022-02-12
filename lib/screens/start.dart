import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/data/assets.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/styled_components/floating_bubble.dart';
import 'package:shair/styled_components/gradient.dart';
import 'package:shair/styled_components/spacers.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';
import 'package:shair/widgets/floating_widget.dart';

const _kCharacterAnimationDuration = Duration(milliseconds: 4000);

const _characterTop = 30.0;
const _characterleft = -60.0;
const _characterWidth = 400.0;
const _characterHeight = 500.0;

const _animY = 20.0;
const _animX = 10.0;

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppTheme appTheme = Provider.of(context);

    final textTheme = theme.textTheme.apply(
      bodyColor: appTheme.onPrimaryColor,
      displayColor: appTheme.onPrimaryColor,
    );
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            FloatingWidget(
              child: Image.asset(ImageAssets.welcomeCharacter),
              left: _characterleft,
              width: _characterWidth,
              height: _characterHeight,
              top: _characterTop,
              varX: _animX,
              varY: _animY,
              duration: _kCharacterAnimationDuration,
            ),
            FloatingBubble(
              left: _characterleft * 3 + _characterWidth,
              top: _characterTop * 2 + _characterHeight,
              color: appTheme.onPrimaryColor.withOpacity(.2),
            ),
            Positioned(
              left: Spacers.kPadding,
              right: Spacers.kPadding,
              top: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    'Share files with your friends',
                    style: textTheme.headline3?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: Spacers.kPadding),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Get access to all your images, documents and more on your phone',
                          style: textTheme.headline6,
                        ),
                      ),
                      Spacers.largeSpacerHz(),
                    ],
                  ),
                  Spacers.smallSpacerVr(),
                  StyledElevatedButton.onPrimary(
                    context,
                    onPressed: RootNavigator.toCharacterSelectScreen,
                    text: 'Let\'s start',
                  ),
                  Spacers.largeSpacerVr(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
