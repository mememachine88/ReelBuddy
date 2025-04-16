import 'dart:convert';
import 'package:fyp/features/maps/data/models/fishing_spots.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/models/tackle_shop.dart';

class MapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TackleShop>> fetchNearbyTackleShops(
    double lat,
    double lng,
  ) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lng&radius=5000&keyword=tackle%20shop&type=store&key=$apiKey',
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);
    final results = data['results'] as List;

    return results
        .map(
          (e) => TackleShop(
            id: e['place_id'],
            name: e['name'],
            lat: e['geometry']['location']['lat'],
            lng: e['geometry']['location']['lng'],
          ),
        )
        .toList();
  }

  Future<void> addFishingSpot(FishingSpot spot) async {
    await _firestore.collection('fishing_spots').add({
      'title': spot.title,
      'description': spot.description,
      'lat': spot.lat,
      'lng': spot.lng,
      'imageBytes':
          spot.imageBytes != null ? base64Encode(spot.imageBytes!) : null,
      'username': spot.username ?? "Anonymous", // ✅ NEW
    });
  }

  Future<List<FishingSpot>> fetchFishingSpots() async {
    final snapshot = await _firestore.collection('fishing_spots').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FishingSpot(
        id: doc.id,
        title: data['title'],
        description: data['description'],
        lat: data['lat'],
        lng: data['lng'],
        imageBytes:
            data['imageBytes'] != null
                ? base64Decode(data['imageBytes'])
                : null,
        username: data['username'] ?? 'Anonymous', // ✅ NEW
      );
    }).toList();
  }
}
