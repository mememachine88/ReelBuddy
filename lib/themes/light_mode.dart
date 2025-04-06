import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  fontFamily: "Satoshi",
  colorScheme: ColorScheme.light(
    surface: Color(
      0xFF495371,
    ), // Dark Blue-Gray: Used for surface elements like cards or sheets
    primary: Color(
      0xFFE2E0C8,
    ), // Light Beige: Main background color and primary theme color
    secondary: Color(
      0xFF74959A,
    ), // Muted Teal: Accent color for buttons and highlights
    tertiary: Color(
      0xFF98B4AA,
    ), // Soft Greenish-Teal: Used for subtle accents or secondary UI elements
    inversePrimary: Color(
      0xFF495371,
    ), // Light Beige: Used as a contrasting color when needed
  ),
  scaffoldBackgroundColor: Color(0xFFE2E0C8),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color(
      0xFF495371,
    ), // Set the background color of the Snackbar
    contentTextStyle: TextStyle(
      color: Colors.white, // Set the text color of the Snackbar
    ),
    actionTextColor: Colors.white,
  ), // Set the action button text color (if any // Light Beige: Background color for the entire app
);
