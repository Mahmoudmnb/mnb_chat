import 'package:flutter/material.dart';

class StateProvider extends ChangeNotifier {
  static ThemeMode _themeMode = ThemeMode.light;
  get themeMode => _themeMode;
  set setThemeMode(value) {
    _themeMode = value;
    notifyListeners();
  }
}
