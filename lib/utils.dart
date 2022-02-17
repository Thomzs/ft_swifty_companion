import 'dart:math';

import 'package:flutter/material.dart';

extension StringExtension on String {
  String useCorrectEllipsis() {
    return replaceAll('', '\u200B');
  }
}

extension truncateOndoubles on double {
  double truncateToDecimalPlaces(int fractionalDigits) => (this * pow(10,
      fractionalDigits)).truncate() / pow(10, fractionalDigits);
}

Widget statWidget(String title, String stat, bool selected) { //Is selected ? text.color = black : text.color = white
  return Expanded(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(title.useCorrectEllipsis(),
                maxLines: 1,
                style: TextStyle(
                    color: selected ? Colors.black26 : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
            ),
            const SizedBox(
              height: 3.0,
            ),
            Flexible(
              child: Text(stat.useCorrectEllipsis(),
                maxLines: 1,
                style: TextStyle(
                    color: selected ? Colors.black26 : Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: 16
                ),
              ),
            ),
          ]
      )
  );
}