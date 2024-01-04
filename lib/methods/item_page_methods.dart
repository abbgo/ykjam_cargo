import 'package:flutter/material.dart';
import 'package:ykjam_cargo/helpers/font_size.dart';

Row rowMethod(String text1, String text2, BuildContext context) {
  return Row(
    children: [
      Text(
        text1,
        style: TextStyle(
          fontSize: calculateFontSize(context, 14),
        ),
      ),
      Text(
        text2,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: calculateFontSize(context, 14),
        ),
      )
    ],
  );
}

Text textMethod(String text, BuildContext context) {
  return Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: calculateFontSize(context, 14),
    ),
  );
}
