import 'package:flutter/material.dart';

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
  String _selectedCategory = '';

  void _selectCategory(String category) {
    final newSelection = category == _selectedCategory ? '' : category;

    setState(() {
      _selectedCategory = newSelection;
    });

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

          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              avatar: isSelected
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
              label: Text(category),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade200,
              onPressed: () => _selectCategory(category),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
