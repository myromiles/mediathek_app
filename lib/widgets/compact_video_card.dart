import 'package:flutter/material.dart';
import '../models/mediathek_item.dart';

class CompactVideoCard extends StatelessWidget {
  final MediathekItem item;
  final VoidCallback onTap;

  const CompactVideoCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1C1C1C),
      elevation: 2,
      margin: const EdgeInsets.all(4.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vorschaubild mit Badges
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: item.urlVideoPreview.isNotEmpty
                      ? Image.network(
                          item.urlVideoPreview,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),

                // Play Button Overlay
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                // Sender Badge (oben links)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.channel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

                // Dauer Badge (unten rechts)
                if (item.formattedDuration.isNotEmpty)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.formattedDuration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Text Informationen (Titel, Thema, Beschreibung)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.topic.isNotEmpty)
                      Text(
                        item.topic,
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        item.displayDescription,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 10, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.formattedDate,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF282828),
      child: const Center(
        child: Icon(Icons.movie_outlined, color: Colors.grey, size: 36),
      ),
    );
  }
}
