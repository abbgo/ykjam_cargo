import 'package:flutter/material.dart';

double calculateFontSize(BuildContext context, double baseSize) {
  // Adjust the base size according to your design preferences
  double screenWidth = MediaQuery.of(context).size.width;

  // Define breakpoints for different font sizes
  if (screenWidth >= 600) {
    return baseSize * 1.5; // Larger font for wider screens
  } else if (screenWidth >= 400) {
    return baseSize * 0.8; // Default font size
  } else {
    return baseSize * 0.85; // Smaller font for narrower screens
  }
}
