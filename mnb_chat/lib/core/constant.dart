import 'dart:io';

import 'package:flutter/material.dart';

import '../featurs/auth/models/user_model.dart';

class Constant {
  static Duration duration = const Duration(milliseconds: 500);
  static UserModel currentUsre =
      UserModel(token: '', name: '', email: '', password: '');
  static Directory? localPath;
  static double heightOfKeyboard = 0;
  //! chat page colors
  static Color chatBackgroundColor = const Color.fromRGBO(221, 231, 227, 1);
  static Color appBarColor = const Color.fromRGBO(248, 248, 248, 1);
  static Color iconColor = const Color.fromRGBO(227, 152, 1, 1);
  static Color sendMessageColor = const Color.fromRGBO(146, 212, 221, 1);
  static Color resivedMessageColor = const Color.fromRGBO(255, 255, 255, 1);
  static Color repliedResivedMessageColor =
      const Color.fromARGB(255, 223, 210, 210);
  static Color messgeRowColor = const Color.fromARGB(255, 136, 133, 133);

  static Color dateColor = const Color.fromRGBO(89, 90, 90, 1);
  static Color repliedSendMessageColor =
      const Color.fromARGB(255, 188, 225, 229);
  static Color inputBottomColor = const Color.fromRGBO(248, 248, 248, 1);
  static Color textInputColor = const Color.fromARGB(255, 233, 227, 227);

  //! Home page colors
  static Color subText = const Color.fromRGBO(103, 103, 103, 1);

  //! dark mode colors
  static Color dChatBackgroundColor = const Color.fromARGB(0, 24, 23, 23);
  static Color dAppBarColor = const Color.fromRGBO(19, 19, 19, 1);
  static Color dIconColor = const Color.fromRGBO(213, 174, 13, 1);
  static Color dSndMessageColor = const Color.fromARGB(255, 87, 181, 194);
  static Color dDateColor = const Color.fromRGBO(117, 115, 115, 1);
  static Color dResivedMessageColor = const Color.fromARGB(255, 43, 42, 42);
  static Color dRepliedResivedMessageColor =
      const Color.fromARGB(255, 48, 46, 46);
  static Color dRepliedSendMessageColor =
      const Color.fromARGB(255, 126, 185, 192);
  static Color dInputBottomColor = const Color.fromRGBO(19, 19, 19, 1);
  static Color dTextInputColor = const Color.fromRGBO(29, 29, 29, 1);

  static ThemeData lightTheme = ThemeData(
      textTheme: const TextTheme(titleLarge: TextStyle(color: Colors.black)),
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          outline: messgeRowColor,
          primary: Colors.black,
          onPrimary: repliedSendMessageColor,
          secondary: resivedMessageColor,
          onSecondary: repliedResivedMessageColor,
          error: iconColor,
          onError: dateColor,
          background: chatBackgroundColor,
          onBackground: sendMessageColor,
          surface: appBarColor,
          surfaceTint: textInputColor,
          onSurface: inputBottomColor));
  static ThemeData darkTheme = ThemeData(
      textTheme: const TextTheme(titleLarge: TextStyle(color: Colors.white)),
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.white70,
          onPrimary: dRepliedSendMessageColor,
          secondary: dResivedMessageColor,
          onSecondary: dRepliedResivedMessageColor,
          error: dIconColor,
          onError: dDateColor,
          background: dChatBackgroundColor,
          onBackground: dSndMessageColor,
          surfaceTint: dTextInputColor,
          surface: dAppBarColor,
          onSurface: dInputBottomColor));
}
