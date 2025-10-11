import 'package:cybercart/theme/dark.dart';
import 'package:cybercart/theme/light.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
import 'pages/home.dart';

void main() {
  runApp(CyberCart());
}

class CyberCart extends StatelessWidget {
  const CyberCart({super.key});
  @override
  Widget build (BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: MaterialHomePage(),
    );
  }
}