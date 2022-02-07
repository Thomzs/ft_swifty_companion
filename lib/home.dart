import 'dart:async';
import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:swifty_companion/utils.dart';
import 'package:swifty_companion/clientApi.dart';

import 'charts.dart';


import 'package:swifty_companion/charts.dart';


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
  final List<String> _names = [];
  final List<double> _levels = [];
  final _skills = [];



  final Color barBackgroundColor = Colors.blueGrey;
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  bool isPlaying = false;



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

    _me = await ca.get('https://api.intra.42.fr/v2/me');

    if (_me != null) {
      _names.clear();
      _levels.clear();
      _skills.clear();
      var rCourse;

      for (var course in _me['cursus_users']) {
        if (course != null && course['cursus']['name'] == '42cursus') {
          rCourse = course;
          break;
        }
      }
      if (rCourse == null) return;
      for (var skill in rCourse['skills']) { //Only get skills > lvl 0 for readability
        if (skill['level'] > 0) {
          _levels.add(skill['level']);
          _names.add(skill['name']);
          _skills.add(skill);
        }
      }
    }
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
                                shrinkWrap: true,
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
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            AspectRatio(
                                              aspectRatio: 1,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  const Text(
                                                      'Skills',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16.0,
                                                          color: Colors.white70
                                                      )
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  SizedBox(
                                                    height: 200,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: BarChart(
                                                        mainBarData(),
                                                        swapAnimationDuration: animDuration,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 12,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ]
                                      )
                                  )
                                ]
                            )
                        )
                    );
                  },
                ),
                Container(color: Colors.orange,)
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

  BarChartGroupData makeGroupData(
      int x,
      double y, {
        bool isTouched = false,
        Color barColor = Colors.white70,
        double width = 16,
        List<int> showTooltips = const [],
      }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          colors: isTouched ? [Colors.yellow] : [barColor],
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.yellow, width: 1)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 20,
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(_names.length, (i) {

    return makeGroupData(i, _levels[i], isTouched: i == touchedIndex);

  });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String name = _names[group.x.toInt()];
              return BarTooltipItem(
                name + '\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.y - 1).toString(),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            return _names[value.toInt()][0].toUpperCase();
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(show: false),
    );
  }
}
