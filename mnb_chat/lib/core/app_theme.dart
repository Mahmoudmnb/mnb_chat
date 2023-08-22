import 'package:flutter/material.dart';

class AppTheme {
  //* this is for color of circle names
  static final Map<String, Color> nameColors = {
    'A': Colors.redAccent,
    'B': Colors.orangeAccent,
    'C': Colors.pinkAccent,
    'D': Colors.yellowAccent,
    'E': Colors.greenAccent,
    'F': Colors.blueAccent,
    'G': Colors.purpleAccent,
    'H': Colors.lightBlueAccent,
    'I': Colors.lightGreenAccent,
    'J': Colors.teal,
    'k': Colors.tealAccent,
    'L': Colors.amberAccent,
    'M': Colors.indigo,
    'N': Colors.indigoAccent,
    'O': Colors.limeAccent,
    'P': Colors.deepPurpleAccent,
    'Q': Colors.cyan,
    'R': Colors.cyanAccent,
    'S': Colors.red[200]!,
    'T': Colors.pink[300]!,
    'U': Colors.red[50]!,
    'V': Colors.purple[200]!,
    'W': Colors.green[200]!,
    'X': Colors.teal[300]!,
    'Y': Colors.deepOrange[300]!,
    'Z': Colors.pink[200]!
  };

  static final ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(titleLarge: TextStyle(color: Colors.black)),
      colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xff33bbc5),
          onPrimary: Color(0xffC8FFE0),
          secondary: Color(0xff85e5c5),
          onSecondary: Color.fromARGB(255, 233, 208, 203),
          error: Color(0xffff0060),
          onError: Colors.black54,
          background: Color(0xfffff6f4),
          onBackground: Color.fromARGB(255, 233, 208, 203),
          surface: Color.fromARGB(255, 11, 59, 79),
          onSurface: Color.fromARGB(255, 132, 181, 220)));
  static final ThemeData darkTheme = ThemeData(
      scaffoldBackgroundColor: const Color.fromARGB(255, 65, 63, 63),
      textTheme: const TextTheme(titleLarge: TextStyle(color: Colors.white)),
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xff33bbc5),
        onPrimary: Color.fromARGB(255, 45, 63, 53),
        secondary: Color(0xff85e5c5),
        onSecondary: Color.fromARGB(255, 132, 181, 220),
        error: Color(0xffff0060),
        onError: Colors.grey,
        background: Color(0xff181818),
        onBackground: Color.fromARGB(255, 45, 43, 43),
        surface: Color.fromARGB(255, 132, 181, 220),
        onSurface: Color.fromARGB(255, 78, 111, 136),
      ));
}
