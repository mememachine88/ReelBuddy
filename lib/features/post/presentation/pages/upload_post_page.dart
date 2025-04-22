import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/post/presentation/components/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/domain/entities/app_user.dart';
import 'package:fyp/features/auth/presentation/components/my_text_field.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/post/domain/entities/post.dart';
import 'package:fyp/features/post/presentation/components/location_picker.dart';
import 'package:fyp/features/post/presentation/cubits/post_cubit.dart';
import 'package:fyp/features/post/presentation/cubits/post_states.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

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
  double? selectedLat;
  double? selectedLng;

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
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.black,
            backgroundColor: Colors.black,
            dimmedLayerColor: Colors.black87, // dark overlay behind image
            activeControlsWidgetColor: Colors.tealAccent, // sliders & buttons
            cropGridColor: Colors.white30,
            cropFrameColor: Colors.tealAccent,
            showCropGrid: true, // or false if you want a cleaner look
            hideBottomControls: false,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Crop Photo', aspectRatioLockEnabled: true),
        ],
      );

      if (croppedFile != null) {
        final file = File(croppedFile.path);

        setState(() {
          imagePickedFile = PlatformFile(
            name: file.path.split('/').last,
            path: file.path,
            size: file.lengthSync(),
          );
        });
      }
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
      id: docRef.id,
      uid: currentUser!.uid,
      username: currentUser!.username,
      text: textController.text,
      imageUrl: '', // will update after upload
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
      location:
          selectedLocation != null && selectedLat != null && selectedLng != null
              ? "$selectedLocation \n(${selectedLat!.toStringAsFixed(5)}, ${selectedLng!.toStringAsFixed(5)})"
              : null,
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Create Post", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: uploadPost,
            child: const Text("Done", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            currentUser?.username ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Image preview
                      if (imagePickedFile != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedLocation != null ||
                                (selectedLat != null && selectedLng != null))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: Colors.tealAccent,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        shareLocation
                                            ? "$selectedLocation\n(${selectedLat?.toStringAsFixed(5)}, ${selectedLng?.toStringAsFixed(5)})"
                                            : selectedLocation ?? "",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Center(
                              child: SizedBox(
                                width: 300,
                                height: 300,
                                child: Image.file(
                                  File(imagePickedFile!.path!),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // Caption input
                      Expanded(
                        child: TextField(
                          controller: textController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: "Tell us about something...",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.alternate_email, color: Colors.white),
              IconButton(
                icon: Icon(Icons.image, color: Colors.white),
                onPressed: pickImage,
              ),
              IconButton(
                icon: Icon(
                  CupertinoIcons.location_circle_fill,
                  color: Colors.white,
                ),
                onPressed: () async {
                  final result = await LocationPickerModal.show(context);
                  if (result != null) {
                    setState(() {
                      selectedLocation = result["name"];
                      selectedLat = result["lat"];
                      selectedLng = result["lng"];
                      shareLocation = !(result["useSearchName"] ?? false);
                    });
                  }
                },
              ),

              /// 👇 Keyboard dismiss icon
              IconButton(
                icon: Icon(Icons.keyboard_hide, color: Colors.white),
                onPressed: () => FocusScope.of(context).unfocus(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
