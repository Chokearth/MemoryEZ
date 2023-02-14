import 'package:flutter/material.dart';

var appTheme = ThemeData(
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme:  const TextTheme(

  ),
);

var appDarkTheme = ThemeData.dark().copyWith(
  primaryColor: Colors.purple[500],
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.purple,
    ),
  ),
);
