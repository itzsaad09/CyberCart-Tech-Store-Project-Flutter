import 'package:flutter/material.dart';

// --- Data (Categories remain the same) ---
final List<String> productCategories = [
  'All',
  'Airpods',
  'Charger & Cables',
  'Gaming',
  'Handsfree',
  'Headphones',
  'Phone Holder',
  'Microphone',
  'Smart Watches',
  'Speakers',
  'Tripods',
];

class CategoryTab extends StatefulWidget {
  final ValueChanged<String>? onCategorySelected;

  const CategoryTab({super.key, this.onCategorySelected});

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  // MODIFIED: Initialize to a null-like string that won't match any category.
  String _selectedCategory = ''; 

  void _selectCategory(String category) {
    // Logic to allow deselection if the same chip is tapped again
    final newSelection = category == _selectedCategory ? '' : category;

    setState(() {
      _selectedCategory = newSelection;
    });
    // Call the parent callback function, passing the newly selected category or an empty string for deselection
    widget.onCategorySelected?.call(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8.0), 
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), 
        scrollDirection: Axis.horizontal,
        itemCount: productCategories.length,
        itemBuilder: (context, index) {
          final category = productCategories[index];
          // Logic checks against the empty string default
          final isSelected = category == _selectedCategory; 

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              // Checkmark is only shown if the chip is actually selected
              avatar: isSelected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
              label: Text(category),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
              onPressed: () => _selectCategory(category),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}