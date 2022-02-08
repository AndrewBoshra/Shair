import 'dart:math';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shair/constants/colors.dart';
import 'package:shair/data/assets.dart';
import 'package:shair/data/config.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/styled_components/avatar.dart';
import 'package:shair/styled_components/gradient.dart';
import 'package:shair/styled_components/spacers.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';
import 'package:shair/widgets/rounded_button.dart';
import 'package:provider/provider.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({Key? key}) : super(key: key);

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  final _carouselController = CarouselController();
  final _textController = TextEditingController();
  String _selectedCharacter = ImageAssets.getAllCharacter()[0];

  Widget _buildCharacters(BoxConstraints constraints) {
    final assetImages = ImageAssets.getAllCharacter();

    final characters =
        assetImages.map((e) => CharacterAvatar(image: e)).toList();

    const maxWidth = 800.0;
    const widthBreakPoint = 600;

    var vpFraction = constraints.biggest.width < widthBreakPoint ? .5 : .3;

    final buttons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RoundedButton(
            onPressed: _carouselController.previousPage,
            child: const Icon(Icons.arrow_back)),
        RoundedButton(
            onPressed: _carouselController.nextPage,
            child: const Icon(Icons.arrow_forward)),
      ],
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: maxWidth,
        minWidth: 200 * 3,
      ),
      child: Column(
        children: [
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              onPageChanged: (index, reason) =>
                  _selectedCharacter = assetImages[index],
              height: 200,
              enlargeCenterPage: true,
              viewportFraction: vpFraction,
              aspectRatio: 1,
            ),
            items: characters,
          ),
          buttons,
        ],
      ),
    );
  }

  void _handlePress() {
    final config = context.read<Config>();
    config.name = _textController.value.text;
    config.character = _selectedCharacter;
    config.isFirstTime = false;

    config.save();
    RootNavigator.toHomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GradientBackground(
        colors: const [kColorSecondaryVar, kColorPrimary],
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              children: [
                const Spacer(),
                _buildCharacters(constraints),
                Spacers.mediumSpacerVr(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacers.kPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextField(
                            controller: _textController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.all(Spacers.kPadding),
                              filled: true,
                              fillColor: Colors.white,
                              focusColor: Colors.red,
                              hintText: 'Tell Us Your Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          Spacers.mediumSpacerVr(),
                          Align(
                              alignment: Alignment.centerRight,
                              child: StyledElevatedButton(
                                  onPressed: _handlePress, text: 'Let\'s Go')),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
