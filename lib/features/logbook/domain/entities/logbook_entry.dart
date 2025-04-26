import 'package:flutter/material.dart';

class LogbookEntry {
  final String id;
  final String uid;
  final String species;
  final double length;
  final double weight;
  final DateTime catchDate;
  final TimeOfDay catchTime;
  final String location;
  final double? latitude; // ✅ Added latitude
  final double? longitude; // ✅ Added longitude
  final String? imageUrl;
  final bool isReleased;

  LogbookEntry({
    required this.id,
    required this.uid,
    required this.species,
    required this.length,
    required this.weight,
    required this.catchDate,
    required this.catchTime,
    required this.location,
    this.latitude, // ✅ Added
    this.longitude, // ✅ Added
    this.imageUrl,
    required this.isReleased,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'species': species,
      'length': length,
      'weight': weight,
      'catchDate': catchDate.toIso8601String(),
      'catchTime': '${catchTime.hour}:${catchTime.minute}',
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'isReleased': isReleased,
    };
  }

  factory LogbookEntry.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['catchTime'] as String).split(':');
    return LogbookEntry(
      id: json['id'],
      uid: json['uid'],
      species: json['species'],
      length: (json['length'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      catchDate: DateTime.parse(json['catchDate']),
      catchTime: TimeOfDay(
        hour: int.tryParse(timeParts[0]) ?? 0,
        minute: int.tryParse(timeParts[1]) ?? 0,
      ),
      location: json['location'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'],
      isReleased: json['isReleased'] ?? false,
    );
  }

  LogbookEntry copyWith({String? imageUrl}) {
    return LogbookEntry(
      id: id,
      uid: uid,
      species: species,
      length: length,
      weight: weight,
      catchDate: catchDate,
      catchTime: catchTime,
      location: location,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      isReleased: isReleased,
    );
  }
}
