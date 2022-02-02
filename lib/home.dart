import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swifty_companion/activities.dart';
import 'package:swifty_companion/clientApi.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ButtonStyle style = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
  final ClientApi ca = ClientApi();
  bool logout = false;
  int _selectedIndex = 0;
  PageController pageController = PageController();

  late var _me;

  void onLogOutPressed() async {
    await ca.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    pageController.jumpToPage(index);
  }

  Future<void> getMe() async {
    _me = await ca.get('https://api.intra.42/v2/me/');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Swifty Companion'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: onLogOutPressed,
              ),
            ],
          ),
          body: PageView(
            controller: pageController,
            children: [
              Container(color: Colors.red),
              Container(color: Colors.orange),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            onTap: onTapped,
          ),
        )
    );
  }
}
