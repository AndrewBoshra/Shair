import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shair/data/app_theme.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/data/config.dart';
import 'package:provider/provider.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    context.read<Config>().load().then((value) {
      final config = value as Config;
      RootNavigator.popAll();
      if (config.isFirstTime) {
        RootNavigator.toStartScreen();
      } else {
        RootNavigator.toHomeScreen();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme appTheme = Provider.of(context);

    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      title: 'Shair',
      navigatorKey: RootNavigator.rootNavKey,
      theme: appTheme.themeData.copyWith(
        textTheme: GoogleFonts.rubikTextTheme().apply(
          bodyColor: appTheme.textColor,
          displayColor: appTheme.textColor,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: RootNavigator.loadingScreen,
      onGenerateRoute: RootNavigator.onGenerateRoute,
    );
  }
}
