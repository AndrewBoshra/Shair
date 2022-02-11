import 'package:flutter/material.dart';

const _shadowSize = 20.0;

class CharacterAvatar extends StatelessWidget {
  final String image;
  final Color borderColor;
  final double lineWidth;
  const CharacterAvatar({
    Key? key,
    required this.image,
    this.borderColor = Colors.white,
    this.lineWidth = 5,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: _shadowSize * 2),
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: lineWidth,
        ),
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.4),
            blurRadius: _shadowSize,
            offset: const Offset(0, 15),
          )
        ],
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.contain),
        shape: BoxShape.circle,
      ),
    );
  }
}
