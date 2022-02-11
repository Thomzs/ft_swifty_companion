import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:swifty_companion/utils.dart';

import 'args.dart';
import 'clientApi.dart';


class User extends StatefulWidget {
  const User({Key? key}) : super(key: key);

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> with AutomaticKeepAliveClientMixin<User> {
  final ButtonStyle style = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
  final ClientApi ca = ClientApi();
  bool logout = false;
  PageController pageController = PageController();

  var _me;

  late Args args;

  final List<String> _names = [];
  final List<double> _levels = [];
  final _skills = [];
  final _projects = [];

  final Color barBackgroundColor = Colors.blueGrey;
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  bool isPlaying = false;

  Future<void> getUser() async {

    var tmp = await ca.get(args.url);
    if (tmp != null) _me = tmp;

    if (_me != null) {
      _names.clear();
      _levels.clear();
      _skills.clear();
      _projects.clear();
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
      for (var project in _me['projects_users']) {
        if ((project['cursus_ids'] as List).contains(rCourse['cursus_id'])) {
          _projects.add(project);
        }
      }
    }
  }

  Future<void> updateUser() async {
    await getUser();
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
    super.build(context);

    final tmp = ModalRoute.of(context)!.settings.arguments as Args?;

    if (tmp != null) {
      args = tmp;
    } else {
      args = const Args('https://api.intra.42.fr/v2/me', true);
    }

    return Scaffold(
        appBar: !args.self ? AppBar(
          title: const Text('Search'),
        ) : null,
        body: FutureBuilder(
          future: getUser(),
          builder: (context, snapshots) {
            if (_me == null) return (const Center(child: Text('LOADING')));
            return LayoutBuilder(
                builder: (context, constraints) => RefreshIndicator(
                    onRefresh: updateUser,
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
                                                        width: 16.0,
                                                      ),
                                                      Text(
                                                          _me['location'] ?? 'Unavailable',
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
                                  Column(
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
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                            'Projects',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                                color: Colors.white70
                                            )
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        for (var project in _projects)
                                          SizedBox(
                                              height: 25,
                                              child:
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      (project['project']['name'] as String).useCorrectEllipsis(),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 14.0,
                                                          color: Colors.white70
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: Center(
                                                          child: ClipOval(
                                                            child: Container(
                                                              color: project['validated?'] != null && project['validated?'] == true ?
                                                              Colors.green : project['status'] == 'finished' ? Colors.red : Colors.orange,
                                                              width: 10,
                                                              height: 10,
                                                            ),
                                                          )
                                                      )
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      project['final_mark'] != null ? project['final_mark'].toString() : 'In progress',
                                                      textAlign: TextAlign.right,
                                                    ),
                                                  ),
                                                ],
                                              )
                                          )
                                      ]
                                  )
                                ],
                              )
                          )
                        ]
                    )
                )
            );
          },
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

  @override
  bool get wantKeepAlive => true;
}