import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

import 'clientApi.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final ButtonStyle style = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
  late StreamSubscription _sub;
  final ClientApi ca = ClientApi();
  late bool needToLogIn;


  void errorLogin() {
    showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
          title: Text('Login has failed'),
          content: Text('Please try again'),
        ));
  }

  Future<void> initUniLinks() async {
    _sub = linkStream.listen((String? link) async {
      if (link != null && link.startsWith(ca.redirectUri)) {
        bool auth = await ca.authenticate(link);
        if (auth) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          errorLogin();
        }
      }
    }, onError: (err) {
      errorLogin();
    });
  }

  @override
  Widget build(BuildContext context) {

    initUniLinks();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swifty Companion'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                style: style,
                onPressed: () async {
                  await ca.login();
                  },
                child: const Text('LOG IN WITH 42')
            ),
          ],
        ),
      ),
      bottomNavigationBar: null,
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}