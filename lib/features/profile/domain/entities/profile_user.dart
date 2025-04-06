import 'package:flutter/material.dart';
import 'package:fyp/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageUrl;
  final List<String> followers;
  final List<String> following;

  ProfileUser({
    required super.uid,
    required super.email,
    required super.name,
    required super.username,
    required this.bio,
    required this.profileImageUrl,
    required this.followers,
    required this.following,
  });

  //method to update profile
  ProfileUser copyWith({
    String? bio,
    String? profileImageUrl,
    List<String>? newFollowers,
    List<String>? newFollowing,
  }) {
    return ProfileUser(
      uid: uid,
      email: email,
      name: name,
      username: username,
      bio: bio ?? this.bio,
      profileImageUrl:
          profileImageUrl ??
          this.profileImageUrl, // No need for newProfileImageUrl
      followers: newFollowers ?? followers,
      following: newFollowing ?? following,
    );
  }

  // convert profile user to json
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "username": username,
      "bio": bio,
      "profileImageUrl": profileImageUrl,
      "followers": followers,
      "following": following,
    };
  }

  //convert json to profile user
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json["uid"],
      email: json["email"],
      name: json["name"],
      username: json["username"],
      bio: json["bio"] ?? "",
      profileImageUrl: json["profileImageUrl"] ?? "",
      followers: List<String>.from(json["followers"] ?? []),
      following: List<String>.from(json["following"] ?? []),
    );
  }
}
