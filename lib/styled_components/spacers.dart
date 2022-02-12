import 'package:flutter/material.dart';

const _smallSpacer = 20.0;
const _mediumSpacer = 40.0;
const _largeSpacer = 80.0;

const _smallHzSpacer = 10.0;
const _mediumHzSpacer = 20.0;
const _largeHzSpacer = 40.0;

abstract class Spacers {
  static const kPadding = 20.0;

  static Widget smallSpacerHz() {
    return const SizedBox(
      width: _smallHzSpacer,
    );
  }

  static Widget mediumSpacerHz() {
    return const SizedBox(
      width: _mediumHzSpacer,
    );
  }

  static Widget largeSpacerHz() {
    return const SizedBox(
      width: _largeHzSpacer,
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
