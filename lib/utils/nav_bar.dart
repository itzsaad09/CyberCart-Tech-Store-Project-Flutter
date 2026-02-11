import 'package:cybercart/pages/home.dart';
import 'package:cybercart/pages/messages.dart';
import 'package:cybercart/pages/cart.dart';
import 'package:cybercart/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    MessagesScreen(),
    Cart(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        items: const [
          CurvedNavigationBarItem(
            child: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.person_outlined),
            label: 'Account',
          ),
        ],
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        height: 65,
        animationCurve: Curves.easeInOut,
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
