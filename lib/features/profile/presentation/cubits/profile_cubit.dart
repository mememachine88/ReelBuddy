import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/profile/domain/repos/profile_repo.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_states.dart';
import 'package:fyp/features/profile/domain/entities/profile_user.dart';
import 'package:fyp/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.profileRepo, required this.storageRepo})
    : super(ProfileInitial());

  // Fetch user profile
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError("User not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // Update profile
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());

    try {
      // Get current user profile
      final currentUser = await profileRepo.fetchUserProfile(uid);
      if (currentUser == null) {
        emit(ProfileError("Failed to fetch user for profile update"));
        return;
      }

      // Initialize imageDownloadUrl with existing image
      String? imageDownloadUrl = currentUser.profileImageUrl;

      // Upload new profile image if provided
      if (imageMobilePath != null) {
        imageDownloadUrl = await storageRepo.uploadProfileImage(
          imageMobilePath,
          uid,
        );
      }

      // Create updated profile with fallback values
      final updatedProfile = currentUser.copyWith(
        bio: newBio ?? currentUser.bio, // Keep old bio if newBio is null
        profileImageUrl:
            imageDownloadUrl, // Keep old image if new image is not uploaded
      );

      // Update in repository
      await profileRepo.updateProfile(updatedProfile);

      // Emit the updated profile
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError("Error updating profile: $e"));
    }
  }
}
