import 'package:flutter/material.dart';
import 'package:shair/data/room.dart';
import 'package:shair/widgets/rounded_button.dart';

class RoomWidget extends StatelessWidget {
  const RoomWidget({Key? key, required this.room}) : super(key: key);
  final Room room;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      width: 100,
      height: 100,
    );
    RoundedButton(
      onPressed: () {},
      child: const Icon(Icons.dangerous),
    );
  }
}
