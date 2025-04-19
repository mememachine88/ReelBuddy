// fishID/data/firebase_scan_repo.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/scan_result.dart';
import '../domain/repo/scan_repo.dart';

class FirebaseScanRepo implements ScanRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveScan(String uid, ScanResult result) async {
    await _firestore.collection("fish_scans").add({
      ...result.toJson(),
      "uid": uid,
    });
  }

  @override
  Future<List<ScanResult>> fetchUserScans(String uid) async {
    final snapshot =
        await _firestore
            .collection("fish_scans")
            .where("uid", isEqualTo: uid)
            .orderBy("timestamp", descending: true)
            .get();

    return snapshot.docs.map((doc) => ScanResult.fromJson(doc.data())).toList();
  }
}
