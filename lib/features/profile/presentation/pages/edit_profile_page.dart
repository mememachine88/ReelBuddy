import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/components/my_text_field.dart';
import 'package:fyp/features/auth/presentation/components/password_strength.dart';
import 'package:fyp/features/post/presentation/components/image_picker.dart';
import 'package:fyp/features/profile/domain/entities/profile_user.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_states.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePage();
}

class _EditProfilePage extends State<EditProfilePage> {
  PlatformFile? imagePickedFile;

  final bioTextController = TextEditingController();
  final nameTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final currentPasswordController = TextEditingController();
  bool isPasswordVerified = false;

  String? selectedGender;
  double passwordStrength = 0.0;

  // Pick profile image
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
      });
    }
  }

  Future<bool> showPasswordVerificationDialog() async {
    final currentPasswordController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Verify Password"),
            content: TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Enter current password",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final credential = EmailAuthProvider.credential(
                      email: widget.user.email,
                      password: currentPasswordController.text,
                    );
                    await user?.reauthenticateWithCredential(credential);
                    Navigator.of(context).pop(true);
                  } catch (e) {
                    Navigator.of(context).pop(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Incorrect current password."),
                      ),
                    );
                  }
                },
                child: Text(
                  "Verify",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ],
          ),
    );

    return confirmed == true;
  }

  @override
  void initState() {
    super.initState();
    bioTextController.text = widget.user.bio;
    nameTextController.text = widget.user.name;
    selectedGender = widget.user.gender;
    passwordTextController.addListener(() {
      setState(() {}); // Rebuilds the widget on every password input
    });
  }

  // Attempt to update profile after confirmation
  void updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();
    final String uid = widget.user.uid;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;

    final String? newBio =
        (bioTextController.text.trim() != widget.user.bio.trim())
            ? bioTextController.text.trim()
            : null;

    final String? newName =
        (nameTextController.text.trim() != widget.user.name.trim())
            ? nameTextController.text.trim()
            : null;

    final String? newGender =
        (selectedGender != null &&
                selectedGender!.trim().isNotEmpty &&
                selectedGender != widget.user.gender)
            ? selectedGender
            : null;

    final bool imageChanged = imagePickedFile != null;
    final bool passwordChanged = passwordTextController.text.isNotEmpty;

    final bool shouldUpdateProfile =
        newBio != null || newName != null || newGender != null || imageChanged;
    final bool shouldUpdatePassword = passwordChanged;

    if (!shouldUpdateProfile && !shouldUpdatePassword) {
      Navigator.pop(context);
      return;
    }

    if (passwordChanged &&
        passwordTextController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    final confirmed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirm Changes"),
            content: const Text(
              "Are you sure you want to update your profile?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Yes, update",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      // 🖼️ Update profile
      final updates = <String, dynamic>{};

      if (newBio != null) updates['bio'] = newBio;
      if (newName != null) updates['name'] = newName;
      if (newGender != null) updates['gender'] = newGender;

      if (imageMobilePath != null) {
        final downloadUrl = await profileCubit.uploadProfileImage(
          uid,
          File(imageMobilePath),
        );
        updates['profileImageUrl'] = downloadUrl;
      }

      if (updates.isNotEmpty) {
        await profileCubit.updateProfileData(uid, updates);
      }

      if (shouldUpdatePassword) {
        final user = FirebaseAuth.instance.currentUser;
        final email = user?.email ?? widget.user.email;
        await reauthenticateAndChangePassword(
          email,
          currentPasswordController.text,
          passwordTextController.text,
        );
      }

      // 🚨 MOST IMPORTANT: fetch updated profile BEFORE popping
      await profileCubit.fetchUserProfile(uid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully.")),
      );

      Navigator.pop(context, true); // ✅ Now it pops cleanly with new data ready
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: ${e.toString()}")),
      );
    }
  }

  Future<void> reauthenticateAndChangePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      // Reauthenticate
      await user?.reauthenticateWithCredential(credential);

      // Update password
      await user?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception("Password update failed: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          // ✅ REMOVE Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully.")),
          );
          // DO NOTHING here. Pop is handled inside updateProfile().
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to update profile: ${state.message}"),
            ),
          );
        }
      },

      builder: (context, state) {
        if (state is ProfileLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingAnimationWidget.dotsTriangle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    size: 70,
                  ),
                  SizedBox(height: 16),
                  Text("Updating profile..."),
                ],
              ),
            ),
          );
        } else {
          return buildEditPage();
        }
      },
    );
  }

  // Build profile edit form UI
  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Profile"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              width: double.infinity,
              color: Theme.of(context).colorScheme.surface,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child:
                        (!kIsWeb && imagePickedFile != null)
                            ? Image.file(
                              File(imagePickedFile!.path!),
                              fit: BoxFit.cover,
                            )
                            : (widget.user.profileImageUrl.isNotEmpty)
                            ? CachedNetworkImage(
                              imageUrl: widget.user.profileImageUrl,
                              placeholder:
                                  (context, url) =>
                                      LoadingAnimationWidget.dotsTriangle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.inversePrimary,
                                        size: 70,
                                      ),
                              errorWidget:
                                  (context, url, error) => Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                              fit: BoxFit.cover,
                            )
                            : Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: MediaQuery.of(context).size.width / 2 - 60,
                    child: GestureDetector(
                      onTap: () async {
                        final file = await ImagePickerModal.show(context);
                        if (file != null) {
                          setState(() {
                            imagePickedFile = PlatformFile(
                              name: file.path.split('/').last,
                              path: file.path,
                              size: file.lengthSync(),
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              width: double.infinity,
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "BIO",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MyTextField(
                    controller: bioTextController,
                    hintText: "Please tell us about yourself",
                    obscureText: false,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  MyTextField(
                    controller: nameTextController,
                    hintText: "Enter your name",
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Change Password",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () async {
                      if (!isPasswordVerified) {
                        final verified = await showPasswordVerificationDialog();
                        if (!verified) return;
                        setState(() => isPasswordVerified = true);
                      }
                    },
                    child: AbsorbPointer(
                      absorbing: !isPasswordVerified,
                      child: MyTextField(
                        controller: passwordTextController,
                        hintText: "Enter new password",
                        obscureText: true,
                      ),
                    ),
                  ),
                  if (passwordTextController.text.isNotEmpty)
                    PasswordStrengthIndicator(
                      password: passwordTextController.text,
                    ),
                  const SizedBox(height: 16),

                  const Text(
                    "Confirm New Password",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      if (!isPasswordVerified) {
                        final verified = await showPasswordVerificationDialog();
                        if (!verified) return;
                        setState(() => isPasswordVerified = true);
                      }
                    },
                    child: AbsorbPointer(
                      absorbing: !isPasswordVerified,
                      child: MyTextField(
                        controller: confirmPasswordController,
                        hintText: "Confirm new password",
                        obscureText: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Save Changes"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
