import 'package:flutter/material.dart';
import '../models/mediathek_item.dart';

class VideoCard extends StatelessWidget {
  final MediathekItem item;
  final VoidCallback onTap;

  const VideoCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Bereich mit Channel Badge und Play Button Overlay
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

                // Dunkler Overlay-Verlauf für Lesbarkeit
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),

                // Play Icon in der Mitte
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),

                // Sender Tag oben links
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.channel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),

                // Dauer Badge unten rechts
                if (item.formattedDuration.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.formattedDuration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Text Informationen
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.topic.isNotEmpty)
                    Text(
                      item.topic.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.displayDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        item.formattedDate,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: const Center(
        child: Icon(
          Icons.movie_creation_outlined,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }
}
