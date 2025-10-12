import 'package:cybercart/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _screens = const [
    MaterialHomePage(),

    Text('Explore/Search View'),

    Text('Cart View'),

    Text('Profile View'),
  ];

  @override
  Widget build(BuildContext context) {
    final Color barColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _screens.elementAt(_selectedIndex),
        ),
      ),

      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _selectedIndex,
        height: 75.0,
        items: [
          CurvedNavigationBarItem(
            child: Icon(Icons.home_outlined, size: 30),
            label: 'Home',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.search_outlined, size: 30),
            label: 'Search',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.shopping_cart_outlined, size: 30),
            label: 'Cart',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.person_outlined, size: 30),
            label: 'Profile',
          ),
        ],
        color: barColor,
        buttonBackgroundColor: barColor,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
