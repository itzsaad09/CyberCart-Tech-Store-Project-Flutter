import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSearchBar(
          controller: _searchController,
          label: 'Search...',
          searchStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
          ),
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
          onFieldSubmitted: (value) {
            // Show a snackbar with the search text
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You searched for: $value')),
            );
          },
        ),
      ],
    );
  }
}
