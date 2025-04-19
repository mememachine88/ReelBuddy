import 'package:cloud_firestore/cloud_firestore.dart';

class SOSAlert {
  final String id;
  final String senderUid;
  final String senderName;
  final String senderUsername;
  final String senderProfileImageUrl;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String receiverUid;
  final bool isRead;

  SOSAlert({
    required this.id,
    required this.senderUid,
    required this.senderName,
    required this.senderUsername,
    required this.senderProfileImageUrl,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.receiverUid,
    this.isRead = false, // default false
  });
  factory SOSAlert.empty() {
    return SOSAlert(
      id: '',
      senderUid: '',
      senderName: '',
      senderUsername: '',
      senderProfileImageUrl: '',
      latitude: 0.0,
      longitude: 0.0,
      timestamp: DateTime.now(),
      receiverUid: '',
      isRead: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderUid': senderUid,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'senderProfileImageUrl': senderProfileImageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'receiverUid': receiverUid,
      'isRead': isRead,
    };
  }

  factory SOSAlert.fromJson(Map<String, dynamic> json, String docId) {
    return SOSAlert(
      id: docId,
      senderUid: json['senderUid'],
      senderName: json['senderName'],
      senderUsername: json['senderUsername'],
      senderProfileImageUrl: json['senderProfileImageUrl'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      receiverUid: json['receiverUid'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }
}
