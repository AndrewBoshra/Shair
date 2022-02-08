import 'package:flutter/material.dart';
import 'package:shair/styled_components/gradient.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
