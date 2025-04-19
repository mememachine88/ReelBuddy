import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String type; // 'sos', 'like', 'comment', 'follow'
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String senderUid;
  final String senderUsername;
  final String senderProfileImageUrl;
  final String? postId; // ✅ NEW FIELD

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.senderUid,
    required this.senderUsername,
    required this.senderProfileImageUrl,
    this.postId, // ✅ Add it to constructor
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppNotification(
      id: doc.id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      senderUid: data['senderUid'] ?? '',
      senderUsername: data['senderUsername'] ?? 'Anonymous',
      senderProfileImageUrl: data['senderProfileImageUrl'] ?? '',
      postId: data['postId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
      'senderUid': senderUid,
      'senderUsername': senderUsername,
      'senderProfileImageUrl': senderProfileImageUrl,
      'postId': postId, // ✅ Include this when saving
    };
  }
}
