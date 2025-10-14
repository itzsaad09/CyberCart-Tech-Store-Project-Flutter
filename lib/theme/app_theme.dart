import 'package:cybercart/theme/text_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Color(0xff0589d0),
    scaffoldBackgroundColor: Colors.white,
    textTheme: AppTextTheme.lightTextTheme
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Color(0xff0589d0),
    scaffoldBackgroundColor: Colors.black,
    textTheme: AppTextTheme.darkTextTheme
  );
}