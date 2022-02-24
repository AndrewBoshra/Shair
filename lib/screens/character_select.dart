import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shair/utils/validators.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/data/assets.dart';
import 'package:shair/data/config.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/styled_components/avatar.dart';
import 'package:shair/styled_components/gradient.dart';
import 'package:shair/styled_components/spacers.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';
import 'package:shair/widgets/rounded_button.dart';
import 'package:provider/provider.dart';

final _kInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.all(Spacers.kPadding),
  filled: true,
  fillColor: Colors.white,
  focusColor: Colors.red,
  hintText: 'Tell Us Your Name',
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide.none,
  ),
);

class GoLeftIntent extends Intent {}

class GoRightIntent extends Intent {}

class GoNextIntent extends Intent {}

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({Key? key}) : super(key: key);

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  final _carouselController = CarouselController();
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedCharacter = ImageAssets.getAllCharacter()[0];

  Map<ShortcutActivator, Intent> _keyboardShortCuts(BuildContext context) {
    return {
      LogicalKeySet(LogicalKeyboardKey.arrowLeft): GoLeftIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowRight): GoRightIntent(),
      LogicalKeySet(LogicalKeyboardKey.enter): GoNextIntent(),
      LogicalKeySet(LogicalKeyboardKey.numpadEnter): GoNextIntent(),
    };
  }

  _actions() {
    return {
      GoLeftIntent: CallbackAction<GoLeftIntent>(
        onInvoke: (_) => _carouselController.previousPage(),
      ),
      GoRightIntent: CallbackAction<GoRightIntent>(
          onInvoke: (_) => _carouselController.nextPage()),
      GoNextIntent: CallbackAction<GoNextIntent>(
        onInvoke: (_) => _createUser(),
      ),
    };
  }

  Widget _buildCharacters(BoxConstraints constraints) {
    final assetImages = ImageAssets.getAllCharacter();

    final characters =
        assetImages.map((e) => CharacterAvatar(image: e)).toList();

    const vpFraction = .5;

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
    return Shortcuts(
      shortcuts: _keyboardShortCuts(context),
      child: Actions(
        actions: _actions(),
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
      ),
    );
  }

  void _createUser() {
    final isValid = _formKey.currentState?.validate();
    if (isValid == null || !isValid) return;
    final config = context.read<Config>();
    config.name = _textController.value.text;
    config.character = _selectedCharacter;
    config.isFirstTime = false;

    config.save();

    RootNavigator.popAll();
    RootNavigator.toHomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    final appTheme = AppTheme.of(context);

    return LayoutBuilder(builder: (context, constraints) {
      return GradientBackground(
        colors: [appTheme.secondaryColor, appTheme.primaryColor],
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCharacters(constraints),
                    Spacers.mediumSpacerVr(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacers.kPadding,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _textController,
                              textCapitalization: TextCapitalization.words,
                              decoration: _kInputDecoration,
                              validator:
                                  const EmptyStringValidator('Name').validate,
                            ),
                            Spacers.mediumSpacerVr(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: StyledElevatedButton.onPrimary(
                                context,
                                onPressed: _createUser,
                                text: 'Let\'s Go',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
