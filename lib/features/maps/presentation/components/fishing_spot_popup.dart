import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fyp/features/maps/data/models/fishing_spots.dart';

class FishingSpotPopup extends StatelessWidget {
  final FishingSpot spot;

  const FishingSpotPopup({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (spot.imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  spot.imageBytes!,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                  color: Colors.white10,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'No image posted for this spot',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              spot.description,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Lat: ${spot.lat.toStringAsFixed(4)}',
              style: const TextStyle(color: Colors.white60),
            ),
            Text(
              'Lng: ${spot.lng.toStringAsFixed(4)}',
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 4),
            Text(
              'Shared by: ${spot.username ?? "Anonymous"}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
