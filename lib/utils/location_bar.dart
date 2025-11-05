import 'package:flutter/material.dart';

class LocationBar extends StatelessWidget {
  final String location;
  const LocationBar({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final Brightness platformBrightness = MediaQuery.of(
      context,
    ).platformBrightness;
    final Brightness iconBrightness = platformBrightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    final Color iconColor =
        iconBrightness == Brightness.dark ? Colors.black : Colors.white;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 0, left: 1.0),
        child: Row(
          children: [
            Icon(Icons.location_on, color: iconColor, size: 30),
            const SizedBox(width: 8),
            Text(
              location,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }
}

class WishlistButton extends StatelessWidget {
  final VoidCallback onTap;
  const WishlistButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Brightness platformBrightness = MediaQuery.of(
      context,
    ).platformBrightness;
    final Brightness iconBrightness = platformBrightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    final Color iconColor =
        iconBrightness == Brightness.dark ? Colors.black : Colors.white;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 0, right: 1.0),
        child: IconButton(
          iconSize: 30,
          icon: Icon(Icons.favorite_border, color: iconColor),
          onPressed: onTap,
        ),
      ),
    );
  }
}
