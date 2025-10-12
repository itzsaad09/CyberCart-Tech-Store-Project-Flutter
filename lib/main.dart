import 'package:cybercart/screens/splash_screen.dart';
import 'package:cybercart/theme/app_theme.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';

void main() {
  runApp(CyberCart());
}

class CyberCart extends StatelessWidget {
  const CyberCart({super.key});
  @override
  Widget build (BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: SplashScreen(),
    );
  }
}