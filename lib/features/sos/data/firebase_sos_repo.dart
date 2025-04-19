import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/sos/domain/entities/sos.dart';
import 'package:fyp/features/sos/domain/repo/sos_repo.dart';

class FirebaseSOSRepo implements SOSRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> sendSOSAlert(SOSAlert alert, List<String> followerUids) async {
    for (String uid in followerUids) {
      await _firestore.collection('sos_alerts').add({
        ...alert.toJson(),
        'receiverUid': uid,
        'isRead': false,
      });
    }
  }

  @override
  Future<List<SOSAlert>> fetchReceivedAlerts(String currentUid) async {
    final snapshot =
        await _firestore
            .collection('sos_alerts')
            .where('receiverUid', isEqualTo: currentUid)
            .orderBy('timestamp', descending: true)
            .get();

    print("📥 Fetching SOS alerts for $currentUid");
    print("Total alerts found: ${snapshot.docs.length}");

    return snapshot.docs
        .map((doc) => SOSAlert.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> markAlertAsRead(String alertId) async {
    await FirebaseFirestore.instance
        .collection("sos_alerts")
        .doc(alertId)
        .update({'isRead': true});
  }
}
