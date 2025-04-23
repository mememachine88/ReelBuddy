import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../domain/entities/logbook_entry.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LogbookTile extends StatelessWidget {
  final LogbookEntry entry;
  final VoidCallback? onTap;

  const LogbookTile({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('d. MMM yyyy').format(entry.catchDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🐟 Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: entry.imageUrl ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[800],
                      child: Center(
                        child: LoadingAnimationWidget.dotsTriangle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          size: 70,
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[800],
                      child: const Icon(Icons.broken_image),
                    ),
              ),
            ),
            const SizedBox(width: 12),

            // 📝 Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔠 Species (truncate if long)
                  Text(
                    entry.species,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 6),

                  // 📏 Info Row (wrap if needed)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _infoIconText(
                        Icons.access_time,
                        entry.catchTime.format(context),
                      ),
                      _infoIconText(
                        Icons.straighten,
                        '${entry.length.toStringAsFixed(0)} cm',
                      ),
                      _infoIconText(
                        Icons.monitor_weight,
                        '${entry.weight.toStringAsFixed(1)} kg',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🔁 Released + Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (entry.isReleased)
                  const Icon(Icons.loop, size: 20, color: Colors.orange),
                const SizedBox(height: 12),
                Text(
                  dateFormatted,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to create icon + text pair
  Widget _infoIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
