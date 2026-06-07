import 'package:flutter/material.dart';

class CustomThemes {
  static final light = ThemeData(
    primarySwatch: Colors.pink,
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    cardColor: Colors.white,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );

  static final dark = ThemeData(
    primarySwatch: Colors.pink,
    scaffoldBackgroundColor: Colors.grey[900],
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      elevation: 0,
    ),
    cardColor: Colors.grey[800],
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}