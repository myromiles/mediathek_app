import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/mediathek_item.dart';
import '../screens/video_player_screen.dart';
import 'compact_video_card.dart';

class CategorySectionRow extends StatelessWidget {
  final MediathekCategory category;
  final List<MediathekItem> items;
  final VoidCallback onSeeAllPressed;

  const CategorySectionRow({
    super.key,
    required this.category,
    required this.items,
    required this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sektions-Titel mit Icon und "Alle anzeigen"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(category.icon, color: Colors.blueAccent, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    category.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onSeeAllPressed,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: const [
                      Text(
                        'Alle anzeigen',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.blueAccent, size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontale Liste kompakter Karten
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return SizedBox(
                width: 230,
                child: CompactVideoCard(
                  item: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(item: item),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
