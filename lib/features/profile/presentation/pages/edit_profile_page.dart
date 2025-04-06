import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/components/my_text_field.dart';
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
  // mobile image picker
  PlatformFile? imagePickedFile;

  //bio text controller
  final bioTextController = TextEditingController();

  //pick image
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

  @override
  void initState() {
    super.initState();
    bioTextController.text = widget.user.bio; // Pre-fill bio text field
  }

  void updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();

    //prepare images
    final String uid = widget.user.uid;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;

    if (imagePickedFile != null || newBio != null) {
      await profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
      );

      await profileCubit.fetchUserProfile(widget.user.uid); // Refresh profile
    }
    //nothing to update
    else {
      Navigator.pop(context);
    }
  }

  //Build UI
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.pop(context); // Close edit screen
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

  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Profile"),
        actions: [
          IconButton(onPressed: updateProfile, icon: const Icon(Icons.upload)),
        ],
      ),
      body: Column(
        children: [
          //profile Picture
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.hardEdge,
              child:
                  //display selected image
                  (!kIsWeb && imagePickedFile != null)
                      ? Image.file(
                        File(imagePickedFile!.path!),
                        fit: BoxFit.cover,
                      )
                      :
                      //no image selected -> display existing profile pic
                      CachedNetworkImage(
                        imageUrl: widget.user.profileImageUrl,

                        //loading....
                        placeholder:
                            (context, url) => const CircularProgressIndicator(),

                        //error failed to load
                        errorWidget:
                            (context, url, error) => Icon(
                              Icons.person,
                              size: 72,
                              color: Theme.of(context).colorScheme.secondary,
                            ),

                        //loaded
                        imageBuilder:
                            (context, imageProvider) =>
                                Image(image: imageProvider, fit: BoxFit.cover),
                      ),
            ),
          ),

          const SizedBox(height: 20),

          //pick image button
          Center(
            child: MaterialButton(
              onPressed: pickImage,
              color: Theme.of(context).colorScheme.tertiary,
              child: const Text("Pick Image"),
            ),
          ),

          //Bio
          Text(
            "Bio",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: MyTextField(
              controller: bioTextController,
              hintText: "Enter your new bio...",
              obscureText: false,
            ),
          ),
          Text(
            "Name",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: MyTextField(
              controller: bioTextController,
              hintText: "Name",
              obscureText: false,
            ),
          ),
        ],
      ),
    );
  }
}
