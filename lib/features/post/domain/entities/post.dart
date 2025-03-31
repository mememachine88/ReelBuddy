import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String uid;
  final String username;
  final String text;
  final String imageUrl;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.uid,
    required this.username,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
      id: id,
      uid: uid,
      username: username,
      text: text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,
    );
  }

  //convert post to json

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uid": uid,
      "username": username,
      "text": text,
      "imageUrl": imageUrl,
      "timestamp": Timestamp.fromDate(timestamp),
    };
  }

  //convert json to post

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      uid: json["uid"],
      username: json["username"],
      text: json["text"],
      imageUrl: json["imageUrl"],
      timestamp: (json["timestamp"] as Timestamp).toDate(),
    );
  }
}
