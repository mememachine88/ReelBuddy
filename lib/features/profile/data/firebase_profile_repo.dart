import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/features/profile/domain/entities/profile_user.dart';
import 'package:fyp/features/profile/domain/repos/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      //get user document from firestore
      final userDoc =
          await firebaseFirestore.collection("users").doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();

        if (userData != null) {
          //fetch followers and following
          final followers = List<String>.from(userData["followers"] ?? []);
          final following = List<String>.from(userData["following"] ?? []);
          return ProfileUser(
            uid: uid,
            email: userData['email'],
            name: userData['name'],
            bio: userData['bio'] ?? "",
            username: userData["username"],
            profileImageUrl: userData['profileImageUrl'].toString(),
            following: following,
            followers: followers,
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateProfile(ProfileUser updateProfile) async {
    try {
      await firebaseFirestore.collection("users").doc(updateProfile.uid).update(
        {
          "bio": updateProfile.bio,
          "profileImageUrl": updateProfile.profileImageUrl,
        },
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      final currentUserDoc =
          await firebaseFirestore.collection('users').doc(currentUid).get();
      final targetUserDoc =
          await firebaseFirestore.collection('users').doc(targetUid).get();

      if (currentUserDoc.exists && targetUserDoc.exists) {
        final currentUserData = currentUserDoc.data();
        final List<String> currentFollowing = List<String>.from(
          currentUserData?['following'] ?? [],
        );

        final isFollowing = currentFollowing.contains(targetUid);

        if (isFollowing) {
          // Unfollow
          await firebaseFirestore.collection('users').doc(currentUid).update({
            "following": FieldValue.arrayRemove([targetUid]),
          });

          await firebaseFirestore.collection("users").doc(targetUid).update({
            "followers": FieldValue.arrayRemove([currentUid]),
          });
        } else {
          // Follow
          await firebaseFirestore.collection('users').doc(currentUid).update({
            "following": FieldValue.arrayUnion([targetUid]),
          });

          await firebaseFirestore.collection('users').doc(targetUid).update({
            "followers": FieldValue.arrayUnion([currentUid]), // ✅ fixed here
          });
        }
      }
    } catch (e) {
      print('toggleFollow error: $e');
    }
  }
}
