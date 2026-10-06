import 'package:flutter/material.dart';
import '../models/category_model.dart';

class MainCategoryBar extends StatelessWidget {
  final MediathekCategory selectedCategory;
  final ValueChanged<MediathekCategory> onCategorySelected;

  const MainCategoryBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: MediathekCategory.categories.length,
        itemBuilder: (context, index) {
          final cat = MediathekCategory.categories[index];
          final isSelected = cat.id == selectedCategory.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              avatar: Icon(
                cat.icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : Colors.grey[400],
              ),
              label: Text(
                cat.title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[300],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.blueAccent,
              backgroundColor: const Color(0xFF262626),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.blueAccent : Colors.transparent,
                ),
              ),
              onSelected: (_) => onCategorySelected(cat),
            ),
          );
        },
      ),
    );
  }
}
