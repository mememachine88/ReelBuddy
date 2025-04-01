import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String username;
  final String uid;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.postId,
    required this.username,
    required this.text,
    required this.timestamp,
    required this.uid,
  });

  //convert comment to Json
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uid": uid,
      "postId": postId,
      "username": username,
      "text": text,
      "timestamp": timestamp,
    };
  }

  //convert Json to comment object
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json["id"],
      postId: json["postId"],
      username: json["username"],
      text: json["text"],
      uid: json["uid"],
      timestamp: (json["timestamp"] as Timestamp).toDate(),
    );
  }
}
