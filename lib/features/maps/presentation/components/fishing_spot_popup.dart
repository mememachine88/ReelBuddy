import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fyp/features/maps/data/models/fishing_spots.dart';

class FishingSpotPopup extends StatelessWidget {
  final FishingSpot spot;

  const FishingSpotPopup({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.only(
        top: 24,
        bottom: 16,
        left: 16,
        right: 16, // 👈 increase top
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              spot.imageBytes!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(spot.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(spot.description),
          Text('Lat: ${spot.lat.toStringAsFixed(4)}'),
          Text('Lng: ${spot.lng.toStringAsFixed(4)}'),
          Text('Shared by: ${spot.username ?? "Unknown"}'),
        ],
      ),
    );
  }
}
