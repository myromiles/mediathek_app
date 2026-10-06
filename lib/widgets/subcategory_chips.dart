import 'package:flutter/material.dart';

class SubcategoryChips extends StatelessWidget {
  final List<String> subcategories;
  final String selectedSubcategory;
  final ValueChanged<String> onSubcategorySelected;

  const SubcategoryChips({
    super.key,
    required this.subcategories,
    required this.selectedSubcategory,
    required this.onSubcategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (subcategories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 6.0, bottom: 6.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          final sub = subcategories[index];
          final isSelected = sub == selectedSubcategory ||
              (selectedSubcategory.isEmpty && index == 0);

          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: ActionChip(
              label: Text(
                sub,
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.grey[400],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              backgroundColor: isSelected
                  ? Colors.blueAccent.withOpacity(0.15)
                  : const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? Colors.blueAccent : Colors.grey[800]!,
                ),
              ),
              onPressed: () => onSubcategorySelected(sub),
            ),
          );
        },
      ),
    );
  }
}
