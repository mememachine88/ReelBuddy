import 'dart:io';
import 'package:flutter/material.dart';
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
          children: [
            // 🐟 Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: entry.imageUrl!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
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
                  Text(
                    entry.species,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(entry.catchTime.format(context)),
                      const SizedBox(width: 12),
                      const Icon(Icons.straighten, size: 16),
                      const SizedBox(width: 4),
                      Text('${entry.length.toStringAsFixed(0)} cm'),
                      const SizedBox(width: 12),
                      const Icon(Icons.monitor_weight, size: 16),
                      const SizedBox(width: 4),
                      Text('${entry.weight.toStringAsFixed(1)} kg'),
                    ],
                  ),
                ],
              ),
            ),

            // 🔁 Released Tag + Date
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
}
