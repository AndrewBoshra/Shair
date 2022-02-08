import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shair/root_nav.dart';
import 'package:shair/constants/colors.dart';
import 'package:shair/data/config.dart';
import 'package:shair/screens/start.dart';
import 'package:provider/provider.dart';

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
      setState(() {
        if (config.isFirstTime) {
          RootNavigator.toStartScreen();
        } else {
          RootNavigator.toHomeScreen();
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: RootNavigator.rootNavKey,
      theme: ThemeData.from(
        colorScheme: const ColorScheme(
          background: kColorBackground,
          onBackground: kColorOnBackground,
          primary: kColorPrimary,
          onPrimary: kColorText,
          secondary: kColorSecondary,
          onSecondary: kColorText,
          brightness: Brightness.light,
          error: kColorError,
          onError: kColorOnError,
          surface: kColorSecondaryVar,
          onSurface: kColorText,
        ),
      ).copyWith(
        textTheme: GoogleFonts.rubikTextTheme().apply(
            bodyColor: kColorOnBackground, displayColor: kColorOnBackground),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: RootNavigator.loadingScreen,
      routes: RootNavigator.routes,
    );
  }
}
