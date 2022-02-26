import 'package:flutter/cupertino.dart';

extension Capital on String {
  ///capitalize the first letter of a string
  String capitalize() {
    return substring(0, 1).toUpperCase() + substring(1);
  }
}

extension HFlip on BorderRadius {
  ///capitalize the first letter of a string
  BorderRadius flipped() {
    return BorderRadius.only(
      bottomLeft: bottomRight,
      bottomRight: bottomLeft,
      topLeft: topRight,
      topRight: topLeft,
    );
  }
}
