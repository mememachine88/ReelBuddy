import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/post/domain/entities/comments.dart';

class Post {
  final String id;
  final String uid;
  final String username;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final List<String> likes; //store uid for people liking this post
  final List<Comment> comments;
  Post({
    required this.id,
    required this.uid,
    required this.username,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
      id: id,
      uid: uid,
      username: username,
      text: text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,
      likes: likes,
      comments: comments,
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
      "comments": comments.map((comment) => comment.toJson()).toList(),
    };
  }

  //convert json to post

  factory Post.fromJson(Map<String, dynamic> json) {
    //prepare comments

    final List<Comment> comments =
        (json["comments"] as List<dynamic>?)
            ?.map((commentJson) => Comment.fromJson(commentJson))
            .toList() ??
        [];
    return Post(
      id: json["id"],
      uid: json["uid"],
      username: json["username"],
      text: json["text"],
      imageUrl: json["imageUrl"],
      timestamp: (json["timestamp"] as Timestamp).toDate(),
      likes: List<String>.from(json["likes"] ?? []),
      comments: comments,
    );
  }
}
