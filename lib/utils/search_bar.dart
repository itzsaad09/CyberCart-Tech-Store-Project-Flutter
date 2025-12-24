import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  final ValueChanged<String>? onSubmitted;

  const SearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,

    this.onSubmitted,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      style: const TextStyle(color: Colors.black, fontSize: 16),

      onSubmitted: widget.onSubmitted,

      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search, color: Colors.grey),
          onPressed: () {
            widget.onSubmitted?.call(widget.controller.text);
          },
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
