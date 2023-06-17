import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  //!             ///////////////////////////////   variables   ////////////////////////////////////////////////

  //* this is for light theme and dark them
  static ThemeMode _themeMode = ThemeMode.light;
  get themeMode => _themeMode;
  set setThemeMode(value) {
    _themeMode = value;
    notifyListeners();
  }

  //* this is to know the name of the freind whom chating with
  String _currentFriendNum = '';
  get currentFriendNum => _currentFriendNum;
  set setCurrentFriendNum(value) {
    _currentFriendNum = value;
    notifyListeners();
  }

  //* this is for enable listTile ontap to pervent user from clicking more than one time
  bool _enableListTile = true;
  get enableListTile => _enableListTile;
  set setEnableListTile(value) {
    _enableListTile = value;
    notifyListeners();
  }
}
