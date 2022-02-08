import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shair/data/config.dart';
import 'package:shair/data/room.dart';
import 'package:shair/models/app_model.dart';
import 'package:shair/styled_components/avatar.dart';
import 'package:shair/styled_components/room_radar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppModel appModel = Provider.of(context);

    return Scaffold(
      body: Center(
          child: FutureBuilder<List<Room>>(
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Container();
          }
          return RoomsRadar(rooms: snapshot.data!);
        },
        initialData: const [],
      )),
    );
  }
}
