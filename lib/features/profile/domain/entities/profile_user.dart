import 'package:flutter/material.dart';
import 'package:fyp/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageUrl;

  ProfileUser({
    required super.uid,
    required super.email,
    required super.name,
    required this.bio,
    required this.profileImageUrl,
  });

  //method to update profile
  ProfileUser copyWith({String? bio, String? profileImageUrl}) {
    return ProfileUser(
      uid: uid,
      email: email,
      name: name,
      bio: bio ?? this.bio,
      profileImageUrl:
          profileImageUrl ??
          this.profileImageUrl, // No need for newProfileImageUrl
    );
  }

  // convert profile user to json
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "bio": bio,
      "profileImageUrl": profileImageUrl,
    };
  }

  //convert json to profile user
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json["uid"],
      email: json["email"],
      name: json["name"],
      bio: json["bio"] ?? "",
      profileImageUrl: json["profileImageUrl"] ?? "",
    );
  }
}
