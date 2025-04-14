import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/components/my_text_field.dart';
import 'package:fyp/features/auth/presentation/components/password_strength.dart';
import 'package:fyp/features/post/presentation/components/gender_dropdown.dart';
import 'package:fyp/features/profile/domain/entities/profile_user.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_states.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
                child: const Text("Cancel"),
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
                child: const Text("Verify"),
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
        bioTextController.text.isNotEmpty ? bioTextController.text : null;
    final String? newName =
        nameTextController.text.isNotEmpty ? nameTextController.text : null;
    final String? newGender =
        (selectedGender != null && selectedGender!.trim().isNotEmpty)
            ? selectedGender
            : widget.user.gender;
    final String? newPassword =
        passwordTextController.text.isNotEmpty
            ? passwordTextController.text
            : null;

    final shouldUpdate =
        imagePickedFile != null ||
        newBio != null ||
        newName != null ||
        newGender != null ||
        newPassword != null;

    if (!shouldUpdate) {
      Navigator.pop(context);
      return;
    }
    //check password
    if (passwordTextController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return; // Stop update if passwords mismatch
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
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes, update"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        newName: newName,
        newGender: newGender,
        imageMobilePath: imageMobilePath,
      );

      await profileCubit.fetchUserProfile(uid);
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully.")),
          );
          Navigator.pop(context);
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
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
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
      //App bar
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Profile"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        actions: [
          IconButton(onPressed: updateProfile, icon: const Icon(Icons.upload)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child:
                    (!kIsWeb && imagePickedFile != null)
                        ? Image.file(
                          File(imagePickedFile!.path!),
                          fit: BoxFit.cover,
                        )
                        : CachedNetworkImage(
                          imageUrl: widget.user.profileImageUrl,
                          placeholder:
                              (context, url) =>
                                  const CircularProgressIndicator(),
                          errorWidget:
                              (context, url, error) => Icon(
                                Icons.person,
                                size: 72,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                          imageBuilder:
                              (context, imageProvider) => Image(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                        ),
              ),
            ),
            const SizedBox(height: 16),

            //Select image
            Center(
              child: MaterialButton(
                onPressed: pickImage,
                color: Theme.of(context).colorScheme.tertiary,
                child: const Text("Pick Image"),
              ),
            ),
            const SizedBox(height: 24),

            //Change Name
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

            //Change bio
            const Text(
              "Bio",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            MyTextField(
              controller: bioTextController,
              hintText: "Enter your bio",
              obscureText: false,
            ),
            const SizedBox(height: 16),
            /*
            
            //select gender
            const Text(
              "Gender",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            GenderDropdown(
              selectedGender: selectedGender,
              onChanged: (value) => setState(() => selectedGender = value),
            ),

            const SizedBox(height: 16), 
            
            */

            //change password
            const Text(
              "Change Password",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            //new password
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
              PasswordStrengthIndicator(password: passwordTextController.text),

            const SizedBox(height: 16),

            //confirm password
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
          ],
        ),
      ),
    );
  }
}
