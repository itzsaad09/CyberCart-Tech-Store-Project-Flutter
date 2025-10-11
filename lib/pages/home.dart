import 'package:flutter/material.dart';

class MaterialHomePage extends StatelessWidget {
  const MaterialHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Material Home Page"),
      ),
      body: Center(
        child: Text("Material Home Page"),
      ),
    );
  }
}