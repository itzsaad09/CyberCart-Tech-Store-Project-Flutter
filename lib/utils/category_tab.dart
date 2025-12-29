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

class CategoryTab extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String>? onCategorySelected;

  const CategoryTab({
    super.key,
    required this.selectedCategory,
    this.onCategorySelected,
  });

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

          final isSelected =
              (selectedCategory == '' && category == '') ||
              (category == selectedCategory);

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
              onPressed: () => onCategorySelected?.call(category),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}
