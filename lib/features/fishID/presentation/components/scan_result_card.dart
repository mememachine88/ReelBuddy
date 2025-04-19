// fishID/presentation/widgets/scan_result_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/scan_result.dart';

class ScanResultCard extends StatelessWidget {
  final ScanResult result;
  final File? imageFile; // Optional local image preview (if available)

  const ScanResultCard({super.key, required this.result, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🎣 Result", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              "Species: ${result.speciesName}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Confidence: ${(result.confidence * 100).toStringAsFixed(2)}%",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            imageFile != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(imageFile!, height: 220, fit: BoxFit.cover),
                )
                : const SizedBox(),
            const SizedBox(height: 8),
            Text(
              "Scanned on: ${result.timestamp.toLocal()}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
