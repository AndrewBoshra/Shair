import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/data/config.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/styled_components/avatar.dart';
import 'package:shair/styled_components/gradient.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Config config = Provider.of(context);
    AppTheme appTheme = Provider.of(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  child: CharacterAvatar(image: config.character!),
                ),
              ),
            ),
          ),
          const Spacer()
        ],
      ),
    );
  }
}
