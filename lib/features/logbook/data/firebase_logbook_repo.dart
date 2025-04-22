import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fyp/features/maps/data/models/fishing_spots.dart';
import '../domain/entities/logbook_entry.dart';
import '../domain/repo/logbook_repo.dart';

class FirebaseLogbookRepo implements LogbookRepo {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  @override
  Future<void> addEntry(LogbookEntry entry) async {
    String? imageUrl;

    if (entry.imageUrl != null) {
      final ref = _storage.ref().child('logbook_images/${entry.id}.jpg');
      await ref.putFile(File(entry.imageUrl!));
      imageUrl = await ref.getDownloadURL();
    }

    final withImage = entry.copyWith(imageUrl: imageUrl);
    await _firestore
        .collection('logbook_entries')
        .doc(entry.id)
        .set(withImage.toJson());
  }

  @override
  Future<List<LogbookEntry>> fetchEntries(String uid) async {
    final snap =
        await _firestore
            .collection('logbook_entries')
            .where('uid', isEqualTo: uid)
            .orderBy('catchDate', descending: true)
            .get();

    return snap.docs.map((doc) => LogbookEntry.fromJson(doc.data())).toList();
  }

  @override
  Future<void> deleteEntry(String id) async {
    final docRef = _firestore.collection('logbook_entries').doc(id);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data();
      final imageUrl = data?['imageUrl'] as String?;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          print('⚠️ Failed to delete image from Storage: $e');
        }
      }
    }

    await docRef.delete();
  }

  Future<List<FishingSpot>> fetchUserSpots(String username) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('fishing_spots')
            .where('username', isEqualTo: username)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FishingSpot(
        id: doc.id,
        description: data['description'],
        lat: data['lat'],
        lng: data['lng'],
        username: data['username'],
        imageBytes:
            data['imageBytes'] != null
                ? base64Decode(data['imageBytes'])
                : null,
      );
    }).toList();
  }
}
