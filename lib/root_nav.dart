import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shair/data/room.dart';
import 'package:shair/screens/character_select.dart';
import 'package:shair/screens/create_room.dart';
import 'package:shair/screens/error.dart';
import 'package:shair/screens/home_screen.dart';
import 'package:shair/screens/join_room.dart';
import 'package:shair/screens/loading_screen.dart';
import 'package:shair/screens/room_screen.dart';
import 'package:shair/screens/start.dart';

abstract class RootNavigator {
  static GlobalKey<NavigatorState> rootNavKey = GlobalKey();
  static NavigatorState? get nav => rootNavKey.currentState;

  static get initialRoute => startScreen;

  static Route _materialRoute(Widget screen) =>
      MaterialPageRoute(builder: (context) => screen);
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case startScreen:
        return _materialRoute(const StartScreen());
      case characterSelectScreen:
        return _materialRoute(const CharacterSelectScreen());
      case homeScreen:
        return _materialRoute(const HomeScreen());
      case loadingScreen:
        return _materialRoute(const LoadingScreen());
      case joinRoomScreen:
        return _materialRoute(const JoinRoomScreen());
      case createRoomScreen:
        return _materialRoute(const CreateRoomScreen());
      case roomScreen:
        return _materialRoute(RoomScreen(id: settings.arguments as String));
    }
    return _materialRoute(
        const ErrorScreen(error: 'Oops Some Error Happened '));
  }

  static const String startScreen = '/';
  static const String characterSelectScreen = '/character';
  static const String homeScreen = '/home';
  static const String loadingScreen = '/loading';
  static const String joinRoomScreen = '/rooms';
  static const String createRoomScreen = '/create-room';
  static const String roomScreen = '/room';

  static Future<T?>? _goTo<T, Tout>(String route,
      {bool pop = false, Object? args, Tout? out}) {
    if (pop) {
      return nav?.popAndPushNamed(route, arguments: args, result: out);
    } else {
      return nav?.pushNamed(
        route,
        arguments: args,
      );
    }
  }

  static Future<T?>? toCharacterSelectScreen<T>() {
    return _goTo(characterSelectScreen);
  }

  static Future<T?>? toHomeScreen<T>() {
    return _goTo(homeScreen);
  }

  static void popAll() {
    nav?.popUntil((route) => false);
  }

  static Future<T?>? toStartScreen<T>() {
    return _goTo(startScreen);
  }

  static Future<T?>? toJoinRoomScreen<T>() async {
    return _goTo(joinRoomScreen);
  }

  static Future<T?>? toCreateRoomScreen<T>({bool pop = false}) async {
    return _goTo(createRoomScreen, pop: pop);
  }

  static Future<T?>? toRoomScreen<T>(Room room, {bool pop = false}) async {
    return _goTo(roomScreen, pop: pop, args: room.id);
  }
}
