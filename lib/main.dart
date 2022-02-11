import 'package:flutter/material.dart';
import 'package:swifty_companion/clientApi.dart';
import 'package:swifty_companion/login.dart';
import 'package:swifty_companion/home.dart';

void main() async {
  Widget _defaultHome = const LoginPage();
  ClientApi clientApi = ClientApi();
  const MaterialColor white = MaterialColor(
    0xFFFFFFFF,
    <int, Color>{
      50: Color(0xFFFFFFFF),
      100: Color(0xFFFFFFFF),
      200: Color(0xFFFFFFFF),
      300: Color(0xFFFFFFFF),
      400: Color(0xFFFFFFFF),
      500: Color(0xFFFFFFFF),
      600: Color(0xFFFFFFFF),
      700: Color(0xFFFFFFFF),
      800: Color(0xFFFFFFFF),
      900: Color(0xFFFFFFFF),
    },
  );

  WidgetsFlutterBinding.ensureInitialized();

  bool _result = await clientApi.needToLogIn();
  if (!_result) {
    _defaultHome = const MyHomePage();
  }

  runApp(MaterialApp(
    title: 'Swifty Companions',
    theme: ThemeData.dark(),
    home: _defaultHome,
    routes: <String, WidgetBuilder> {
      '/home': (BuildContext context) => const MyHomePage(),
      '/login': (BuildContext context) => const LoginPage(),
    },
  ));
}