import 'package:flutter/material.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._() : super(ThemeMode.light);

  static final ThemeController instance = ThemeController._();

  bool get isDarkMode {
    return value == ThemeMode.dark;
  }

  void setDarkMode(bool enabled) {
    value = enabled ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }
}
