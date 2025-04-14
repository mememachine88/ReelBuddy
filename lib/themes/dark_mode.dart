import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: "Satoshi",
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF1E2A38),
    primary: Color(0xFFE6E1D2),
    secondary: Color(0xFF5A787E),
    tertiary: Color(0xFF74988F),
    inversePrimary: Color(0xFFF1EFE4),
  ),
  scaffoldBackgroundColor: Color(0xFF121A24),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color(0xFF2C3A4A),
    contentTextStyle: TextStyle(color: Colors.white),
    actionTextColor: Colors.white,
  ),
);
