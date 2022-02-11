import 'package:flutter/cupertino.dart';
import 'package:shair/screens/character_select.dart';
import 'package:shair/screens/create_room.dart';
import 'package:shair/screens/home_screen.dart';
import 'package:shair/screens/join_room.dart';
import 'package:shair/screens/loading_screen.dart';
import 'package:shair/screens/start.dart';

abstract class RootNavigator {
  static GlobalKey<NavigatorState> rootNavKey = GlobalKey();
  static NavigatorState? get nav => rootNavKey.currentState;

  static get initialRoute => startScreen;
  static Map<String, Widget Function(BuildContext)> get routes => {
        startScreen: (context) => const StartScreen(),
        characterSelectScreen: (context) => const CharacterSelectScreen(),
        homeScreen: (context) => const HomeScreen(),
        loadingScreen: (context) => const LoadingScreen(),
        joinRoomScreen: (context) => const JoinRoomScreen(),
        createRoomScreen: (context) => const CreateRoomScreen(),
      };

  static const String startScreen = '/';
  static const String characterSelectScreen = '/character';
  static const String homeScreen = '/home';
  static const String loadingScreen = '/loading';
  static const String joinRoomScreen = '/rooms';
  static const String createRoomScreen = '/create-room';

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

  static Future<T?>? toCreateRoomScreen<T>() async {
    return _goTo(createRoomScreen);
  }
}
