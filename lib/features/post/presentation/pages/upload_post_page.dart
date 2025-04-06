import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      uid: currentUser!.uid,
      username: currentUser!.username,
      text: textController.text,
      imageUrl: '',
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );

    // 🔹 Get PostCubit and call upload function
    final postCubit = context.read<PostCubit>();

    //upload
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
      //APP BAR
      appBar: AppBar(
        title: const Text("Create Post"),
        centerTitle: true,
        actions: [
          //upload button
          IconButton(onPressed: uploadPost, icon: const Icon(Icons.add)),
        ],
      ),

      //Body
      body: Center(
        child: Column(
          children: [
            //image preview
            if (imagePickedFile != null)
              Image.file(File(imagePickedFile!.path!)),

            //pick image button
            MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: const Text("Pick Image"),
            ),

            //caption text box
            MyTextField(
              controller: textController,
              hintText: "Insert Caption Here",
              obscureText: false,
            ),
          ],
        ),
      ),
    );
  }
}
