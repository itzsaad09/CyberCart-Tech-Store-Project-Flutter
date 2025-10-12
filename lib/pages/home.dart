import 'package:flutter/material.dart' hide SearchBar;
import 'package:cybercart/utils/search_bar.dart';

class MaterialHomePage extends StatelessWidget {
  const MaterialHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchBar(),
      ), 
      body: Center(
        child: Text("Material Home Page"),
      ),
    );
  }
}