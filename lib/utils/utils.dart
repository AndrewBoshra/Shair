String arabicToEnglish(Match match) {
  final letter = match.input[match.start];
  return String.fromCharCode(letter.codeUnitAt(0) - 1584);
}
