import 'package:flutter/material.dart';

extension StringExtension on String {
  String useCorrectEllipsis() {
    return replaceAll('', '\u200B');
  }
}

Widget statWidget(String title, String stat) {
  return Expanded(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(title.useCorrectEllipsis(),
                maxLines: 1,
                style: const TextStyle(
                    color: Colors.grey,
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
                style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: 16
                ),
              ),
            ),
          ]
      )
  );
}