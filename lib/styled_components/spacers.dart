import 'package:flutter/material.dart';

const _smallSpacer = 20.0;
const _mediumSpacer = 40.0;
const _largeSpacer = 80.0;

abstract class Spacers {
  static const kPadding = 20.0;

  static Widget smallSpacerHz() {
    return const SizedBox(
      width: _smallSpacer,
    );
  }

  static Widget mediumSpacerHz() {
    return const SizedBox(
      width: _mediumSpacer,
    );
  }

  static Widget largeSpacerHz() {
    return const SizedBox(
      width: _largeSpacer,
    );
  }

  static Widget smallSpacerVr() {
    return const SizedBox(
      height: _smallSpacer,
    );
  }

  static Widget mediumSpacerVr() {
    return const SizedBox(
      height: _mediumSpacer,
    );
  }

  static Widget largeSpacerVr() {
    return const SizedBox(
      height: _largeSpacer,
    );
  }
}
