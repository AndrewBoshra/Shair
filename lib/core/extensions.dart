extension Capital on String {
  ///capitalize the first letter of a string
  String capitalize() {
    return substring(0, 1).toUpperCase() + substring(1);
  }
}
