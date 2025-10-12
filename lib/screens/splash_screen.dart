import 'dart:async';
// import 'package:cybercart/pages/home.dart';
import 'package:cybercart/utils/nav_bar.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => NavigationMenu(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(138, 210, 255, 1),
        // color: Color.fromRGBO(5, 138, 210, 1.000),
        child: Center(
          child: Image.asset(
            'assets/logo.png',
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }
}