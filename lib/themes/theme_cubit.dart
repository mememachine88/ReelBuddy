import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'light_mode.dart';
import 'dark_mode.dart'; // <-- your custom dark theme

class ThemeCubit extends Cubit<ThemeData> {
  bool isDarkMode = false;

  ThemeCubit() : super(lightMode);

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    emit(isDarkMode ? darkMode : lightMode);
  }
}
