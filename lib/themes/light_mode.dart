import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  fontFamily: "Satoshi",
  colorScheme: ColorScheme.light(
    surface: Color(0xFF3E4A61), // bolder navy
    primary: Color(0xFFF1EFE4), // warmer cream beige
    secondary: Color(0xFF678C91), // soft sea blue
    tertiary: Color(0xFF8BA89F), // subtle seafoam
    inversePrimary: Color(0xFF3E4A61),
  ),
  scaffoldBackgroundColor: Color(0xFFF1EFE4),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color(0xFF3E4A61),
    contentTextStyle: TextStyle(color: Colors.white),
    actionTextColor: Colors.white,
  ),
);
