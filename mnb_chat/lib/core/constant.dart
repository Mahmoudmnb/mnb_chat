import 'dart:io';

import '../featurs/auth/models/user_model.dart';

class Constant {
  static Duration duration = const Duration(milliseconds: 500);
  static UserModel currentUsre =
      UserModel(token: '', name: '', email: '', password: '');
  static Directory? appPath;
  static double heightOfKeyboard = 0;
}
