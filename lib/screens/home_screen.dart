import 'package:flutter/material.dart';
import 'package:shair/styled_components/gradient.dart';
import 'package:shair/styled_components/styled_elevated_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: Column(
          children: [
            StyledElevatedButton.primary(
              context,
              onPressed: () {},
              text: 'Color',
            )
          ],
        ),
      ),
    );
  }
}
