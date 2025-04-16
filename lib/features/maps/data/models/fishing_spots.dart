import 'dart:typed_data';

class FishingSpot {
  final String id;
  final String title;
  final String description;
  final double lat;
  final double lng;
  final Uint8List? imageBytes;
  final String? username; // 👈 NEW

  FishingSpot({
    required this.id,
    required this.title,
    required this.description,
    required this.lat,
    required this.lng,
    this.imageBytes,
    this.username, // 👈 optional
  });
}
