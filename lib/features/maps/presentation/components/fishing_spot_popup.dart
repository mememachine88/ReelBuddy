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
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                alignment: Alignment.center,
                child: Text(
                  'No image posted for this spot',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              spot.description,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Lat: ${spot.lat.toStringAsFixed(4)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 16,
              ),
            ),
            Text(
              'Lng: ${spot.lng.toStringAsFixed(4)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Shared by: ${spot.username ?? "Anonymous"}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
