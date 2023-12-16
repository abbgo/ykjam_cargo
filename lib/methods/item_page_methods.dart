import 'package:flutter/material.dart';

Row rowMethod(String text1, String text2) {
  return Row(
    children: [
      Text(text1),
      Text(
        text2,
        style: const TextStyle(fontWeight: FontWeight.bold),
      )
    ],
  );
}

Text textMethod(String text) {
  return Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.bold),
  );
}
