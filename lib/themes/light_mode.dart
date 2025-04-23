import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  fontFamily: "Satoshi",
  colorScheme: ColorScheme.light(
    surface: Color(0xFFFAF8F1), // bolder navy
    primary: Color(0xFFF1EFE4), // warmer cream beige
    secondary: Color(0xFF678C91), // soft sea blue
    tertiary: Color(0xFF8BA89F), // subtle seafoam
    inversePrimary: Color(0xFF3E4A61), // Overall background color
    error: Color(0xFFB00020), // Standard error color (red)
    onPrimary: Color(0xFF3E4A61), // Text/icons on primary color
    onSecondary: Colors.white, // Text/icons on secondary color
    onTertiary: Colors.white, // Text/icons on tertiary color
    onSurface: Color(
      0xFF3E4A61,
    ), // Text/icons on surfaces // Text/icons on background
  ),
  scaffoldBackgroundColor: Color(0xFFF1EFE4),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color(0xFF3E4A61),
    contentTextStyle: TextStyle(color: Colors.white),
    actionTextColor: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF3E4A61),
    foregroundColor: Colors.white,
  ),
);
