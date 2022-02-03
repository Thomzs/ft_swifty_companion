import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:swifty_companion/utils.dart';
import 'package:swifty_companion/activities.dart';
import 'package:swifty_companion/clientApi.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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

  var _me;

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

  Future<Map?> getMe() async {
    _me = await ca.get('https://api.intra.42.fr/v2/me');
    return _me;
  }

  Future<void> updateMe() async {
    await getMe();
    setState(() {
    });
  }

  ClipOval getLocationColor() {
    if (_me['location'] != null) {
      return ClipOval(
        child: Container(
          color: Colors.green,
          width: 10,
          height: 10,
        ),
      );
    }
    return ClipOval(
      child: Container(
        color: Colors.red,
        width: 10,
        height: 10,
      ),
    );
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
              onPageChanged: (index) => setState(() {
                _selectedIndex = index;
              }),
              children: [
                FutureBuilder(
                  future: getMe(),
                  builder: (context, snapshots) {
                    if (_me == null) return (const Text('AN ERROR HAS OCCURRED'));
                    return LayoutBuilder(
                        builder: (context, constraints) => RefreshIndicator(
                            onRefresh: updateMe,
                            child: ListView(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(20.0),
                                      constraints: BoxConstraints(
                                        minHeight: constraints.minHeight,
                                      ),
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            CircleAvatar(
                                              radius: 56,
                                              backgroundImage: NetworkImage(_me['image_url']),
                                            ),
                                            const SizedBox(
                                              height: 12.0,
                                            ),
                                            Text(
                                              _me['displayname'],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3.0,
                                            ),
                                            Text(
                                              '@' + _me['login'],
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3.0,
                                            ),
                                            Text(
                                              _me['phone'] != null ? 'phone: ' + _me['phone'] : 'null',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  for (var cursus in _me['cursus_users'])
                                                    statWidget(cursus['cursus']['name'], 'lvl: ' + cursus['level'].toString())
                                                ]
                                            ),
                                            const SizedBox(
                                              height: 9.0,
                                            ),
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  statWidget("Correction point(s)", _me['correction_point'].toString()),
                                                  Expanded(
                                                      child: IntrinsicHeight(
                                                          child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                const VerticalDivider(
                                                                  thickness: 1,
                                                                  color: Colors.white,
                                                                ),
                                                                const SizedBox(
                                                                  width: 12.0,
                                                                ),
                                                                Container(
                                                                    child: getLocationColor()
                                                                ),
                                                                const SizedBox(
                                                                  width: 9.0,
                                                                ),
                                                                Text(
                                                                    _me['location'] != null ? _me['location']['host'] : 'Unavailable',
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 16.0,
                                                                        color: Colors.white70
                                                                    )
                                                                )
                                                              ]
                                                          )
                                                      )
                                                  )
                                                ]
                                            )
                                          ]
                                      )
                                  )
                                ]
                            )
                        )
                    );
                  },
                ),
                Container(color: Colors.orange),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          width: 0.1,
                          color: Colors.white
                      )
                  )
              ),
              child: BottomNavigationBar(
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
        )
    );
  }
}
