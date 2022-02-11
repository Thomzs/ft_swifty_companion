import 'package:flutter/material.dart';
import 'package:swifty_companion/search.dart';
import 'package:swifty_companion/clientApi.dart';
import 'user.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final ClientApi ca = ClientApi();
  int _selectedIndex = 0;
  PageController pageController = PageController();

  void onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    pageController.jumpToPage(index);
  }

  void onLogOutPressed() async {
    await ca.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: _selectedIndex == 0 ? AppBar(
              title: const Text('Home'),
              actions: [
                IconButton(
                    onPressed: onLogOutPressed,
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    )
                )
              ],
            ) : null,
            body: PageView(
                controller: pageController,
                children: [
                  Navigator(
                    onGenerateRoute: (settings) {
                      Widget page = const User();
                      return MaterialPageRoute(
                          builder: (_) => page,
                          settings: settings
                      );
                    },
                  ), Navigator(
                    onGenerateRoute: (settings) {
                      Widget page = const Search();
                      if (settings.name == 'user') page = const User();
                      return MaterialPageRoute(
                          builder: (_) => page,
                          settings: settings
                      );
                    },
                  )
                ]
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
