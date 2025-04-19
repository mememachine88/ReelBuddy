import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/profile/presentation/components/location_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/domain/entities/app_user.dart';
import 'package:fyp/features/auth/presentation/components/my_text_field.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/post/domain/entities/post.dart';
import 'package:fyp/features/post/presentation/cubits/post_cubit.dart';
import 'package:fyp/features/post/presentation/cubits/post_states.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  // image picker
  PlatformFile? imagePickedFile;
  String? selectedLocation;
  bool shareLocation = false;

  //text controller ->caption
  final textController = TextEditingController();

  //current user
  AppUser? currentUser;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  //get current user
  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

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

  //create and upload post
  void uploadPost() {
    //check if image and caption is provided

    if (imagePickedFile == null || textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Both image and caption are required")),
      );

      return;
    }
    //create new post object
    final docRef = FirebaseFirestore.instance.collection('posts').doc();

    final newPost = Post(
      id: docRef.id, // ✅ Use Firestore-generated ID
      uid: currentUser!.uid,
      username: currentUser!.username,
      text: textController.text,
      imageUrl: '', // will update after image upload
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
      location: selectedLocation,
    );

    // Call upload function with post + id
    final postCubit = context.read<PostCubit>();
    postCubit.createPost(newPost, imagePickedFile?.path);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  //BUild UI
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostUploading || state is PostLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //else return uploadpage
        return buildUploadPage();
      },
      //go to the previous page when upload is done
      listener: (context, state) {
        if (state is PostLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  //

  //BUild upload page
  Widget buildUploadPage() {
    return Scaffold(
      // APP BAR
      appBar: AppBar(
        title: Text(
          "Create Post",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: uploadPost, icon: const Icon(Icons.add)),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
      ),

      // Body
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image preview or placeholder
            SizedBox(height: 20),
            Stack(
              children: [
                // Image area
                GestureDetector(
                  onTap: pickImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      width: 280,
                      height: 360,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child:
                          imagePickedFile != null
                              ? Image.file(
                                File(imagePickedFile!.path!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.photo,
                                    size: 60,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.inversePrimary,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Tap to select image',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.inversePrimary,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),

                // ✅ Only show the floating icon if image is selected
                if (imagePickedFile != null)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          CupertinoIcons
                              .photo_on_rectangle, // 👈 You can change this line
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        tooltip: 'Change photo',
                        onPressed: pickImage,
                      ),
                    ),
                  ),
              ],
            ),

            LocationSelector(
              onLocationPicked: (name, lat, lng) {
                setState(() {
                  selectedLocation = name;
                });
              },
            ),

            SizedBox(height: 20),
            // Caption text box
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: MyTextField(
                controller: textController,
                hintText: "Insert Caption Here",
                obscureText: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
