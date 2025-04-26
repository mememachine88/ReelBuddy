import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/post/presentation/components/image_picker.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_states.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fyp/features/auth/domain/entities/app_user.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/maps/data/models/fishing_spots.dart';
import 'package:fyp/features/maps/presentation/cubit/map_cubit.dart';
import 'package:fyp/features/post/presentation/components/location_picker.dart';
import 'package:fyp/features/profile/domain/entities/profile_user.dart';

class UploadFishingSpotPage extends StatefulWidget {
  const UploadFishingSpotPage({super.key});

  @override
  State<UploadFishingSpotPage> createState() => _UploadFishingSpotPageState();
}

class _UploadFishingSpotPageState extends State<UploadFishingSpotPage> {
  PlatformFile? imagePickedFile;
  String? selectedLocation;
  bool shareLocation = false;
  double? selectedLat;
  double? selectedLng;
  final textController = TextEditingController();
  AppUser? currentUser;
  ProfileUser? profileUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    final uid = authCubit.currentUser?.uid;

    if (uid != null) {
      final profileCubit = context.read<ProfileCubit>();
      await profileCubit.fetchUserProfile(uid);

      final profileState = profileCubit.state;
      if (profileState is ProfileLoaded) {
        setState(() {
          profileUser = profileState.profile;
          currentUser = profileState.profile;
        });
      }
    }
  }

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
            backgroundColor: Colors.white,
            dimmedLayerColor: Colors.black,
            activeControlsWidgetColor: Colors.tealAccent,
            cropGridColor: Colors.white30,
            cropFrameColor: Colors.tealAccent,
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

  void uploadFishingSpot() {
    if (textController.text.isEmpty ||
        selectedLocation == null ||
        selectedLat == null ||
        selectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location and description are required")),
      );
      return;
    }

    final spot = FishingSpot(
      id: '',
      description: textController.text,
      lat: selectedLat!,
      lng: selectedLng!,
      imageBytes:
          imagePickedFile != null
              ? File(imagePickedFile!.path!).readAsBytesSync()
              : null,
      username: currentUser?.username ?? 'Anonymous',
    );

    context.read<MapCubit>().addFishingSpot(spot);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
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
          "Mark a Fishing Spot",
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: uploadFishingSpot,
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
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                (profileUser?.profileImageUrl.isNotEmpty ==
                                        true)
                                    ? NetworkImage(profileUser!.profileImageUrl)
                                    : null,
                            backgroundColor: Colors.grey,
                            child:
                                (profileUser?.profileImageUrl.isEmpty ?? true)
                                    ? const Icon(Icons.person, size: 30)
                                    : null,
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

                      if (imagePickedFile != null)
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

                      if (selectedLocation != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
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
                                  "$selectedLocation\n(${selectedLat?.toStringAsFixed(5)}, ${selectedLng?.toStringAsFixed(5)})",
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.inversePrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: TextField(
                          controller: textController,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 20,
                          ),
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "Tell us about the spot...",
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
          color: Theme.of(context).colorScheme.primary,
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
