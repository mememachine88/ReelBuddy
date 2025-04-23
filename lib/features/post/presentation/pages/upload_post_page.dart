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
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    final picked = await ImagePickerModal.show(context);
    if (picked != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            statusBarColor: Colors.white,
            backgroundColor: Colors.black,
            dimmedLayerColor: Colors.black87,
            activeControlsWidgetColor: Colors.tealAccent,
            cropGridColor: Colors.white30,
            cropFrameColor: Colors.tealAccent,
            showCropGrid: true,
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
          return Scaffold(
            body: Center(
              child: LoadingAnimationWidget.dotsTriangle(
                color: Theme.of(context).colorScheme.inversePrimary,
                size: 70,
              ),
            ),
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create Post",
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: uploadPost,
            child: Text(
              "Done",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
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
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            currentUser?.username ?? 'Unknown',
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
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
                                    Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.inversePrimary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        shareLocation
                                            ? "$selectedLocation\n(${selectedLat?.toStringAsFixed(5)}, ${selectedLng?.toStringAsFixed(5)})"
                                            : selectedLocation ?? "",
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.inversePrimary,
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
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 20,
                          ),
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "Tell us about something...",
                            hintStyle: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
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

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                onPressed: pickImage,
              ),
              IconButton(
                icon: Icon(
                  CupertinoIcons.location_circle_fill,
                  color: Theme.of(context).colorScheme.inversePrimary,
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
                icon: Icon(
                  Icons.keyboard_hide,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                onPressed: () => FocusScope.of(context).unfocus(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
