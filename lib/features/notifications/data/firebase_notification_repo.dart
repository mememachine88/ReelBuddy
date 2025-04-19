import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/notification.dart';
import '../domain/repo/notification_repo.dart';

class FirebaseNotificationRepo implements NotificationRepo {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<void> sendNotification(
    String receiverUid,
    AppNotification notification,
  ) async {
    final data = notification.toMap();
    data['receiverUid'] = receiverUid;

    await FirebaseFirestore.instance.collection('notifications').add(data);
  }

  @override
  Future<List<AppNotification>> fetchNotifications(String uid) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('notifications')
              .where('receiverUid', isEqualTo: uid)
              .orderBy('timestamp', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("❌ Error in fetchNotifications: $e");
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String uid, String notificationId) async {
    try {
      print("📤 Marking as read: UID = $uid, NotificationID = $notificationId");

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      print("✅ Marked as read");
    } catch (e) {
      print("❌ Failed to mark as read: $e");
      rethrow;
    }
  }
}
