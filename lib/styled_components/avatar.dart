import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shair/data/assets.dart';

import 'package:shair/data/room.dart';

const _shadowSize = 20.0;

class CharacterImage {
  final String path;
  final bool isLocal;
  CharacterImage(this.path, this.isLocal);
  ImageProvider get image => isLocal
      ? FileImage(File(path))
      : NetworkImage(path) as ImageProvider<Object>;
}

class CharacterAvatar extends StatelessWidget {
  final CharacterImage characterImage;
  final Color borderColor;
  final double lineWidth;
  const CharacterAvatar({
    Key? key,
    required this.characterImage,
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
        image:
            DecorationImage(image: characterImage.image, fit: BoxFit.contain),
        shape: BoxShape.circle,
      ),
    );
  }
}

class RoomAvatar extends StatelessWidget {
  const RoomAvatar({
    Key? key,
    required this.characterImage,
  }) : super(key: key);
  final CharacterImage? characterImage;

  @override
  Widget build(BuildContext context) {
    const placeHolder = AssetImage(ImageAssets.logo);

    return CircleAvatar(
      foregroundImage: characterImage?.image ?? placeHolder,
      backgroundImage: placeHolder,
    );
  }
}
