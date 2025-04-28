import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_states.dart';
import 'package:fyp/features/sos/domain/entities/sos.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:fyp/features/sos/presentation/cubit/sos_cubit.dart';
import 'package:uuid/uuid.dart';

class SOSHelper {
  static Future<void> sendSOSLocation({required BuildContext context}) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final authUser = context.read<AuthCubit>().currentUser;
      final profileState = context.read<ProfileCubit>().state;

      if (authUser != null && profileState is ProfileLoaded) {
        final profile = profileState.profile;

        for (final followerUid in profile.followers) {
          final sos = SOSAlert(
            id: const Uuid().v4(),
            senderUid: authUser.uid,
            senderName: profile.name,
            senderUsername: profile.username,
            senderProfileImageUrl: profile.profileImageUrl ?? '',
            latitude: position.latitude,
            longitude: position.longitude,
            timestamp: DateTime.now(),
            receiverUid: followerUid,
            isRead: false,
          );

          await context.read<SOSCubit>().sendSOS(sos, [followerUid]);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("SOS sent to your followers")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not fetch user profile")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sending SOS: $e")));
    }
  }
}
