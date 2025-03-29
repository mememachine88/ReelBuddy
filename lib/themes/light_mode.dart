import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  fontFamily: "Satoshi",
  colorScheme: ColorScheme.light(
    surface: Color(
      0xFFF6F8D5,
    ), // Cream: Background for surfaces like cards or sheets
    primary: Color(
      0xFF205781,
    ), // Deep Blue: Primary color for the app (AppBar, buttons)
    secondary: Color(
      0xFF4F959D,
    ), // Teal: Accent color for highlights and floating action buttons
    tertiary: Color(
      0xFF98D2C0,
    ), // Light Teal: Used for subtle accents or secondary UI elements
    inversePrimary: Color(
      0xFFF6F8D5,
    ), // Cream: Contrasts the primary color (use for inverse themes or light text on deep backgrounds)
  ),
  scaffoldBackgroundColor: Color(
    0xFFF6F8D5,
  ), // Cream: Main background for the app
);
