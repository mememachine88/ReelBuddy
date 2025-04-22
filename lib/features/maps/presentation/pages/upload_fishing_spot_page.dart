import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fyp/features/auth/domain/entities/app_user.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/maps/data/models/fishing_spots.dart';
import 'package:fyp/features/maps/presentation/cubit/map_cubit.dart';
import 'package:fyp/features/post/presentation/components/location_picker.dart';

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

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          dimmedLayerColor: Colors.black87,
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 100,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mark a Fishing Spot",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: uploadFishingSpot,
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
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.tealAccent,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "$selectedLocation\n(${selectedLat?.toStringAsFixed(5)}, ${selectedLng?.toStringAsFixed(5)})",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: TextField(
                          controller: textController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: "Tell us about the spot...",
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
              const Icon(Icons.alternate_email, color: Colors.white),
              IconButton(
                icon: const Icon(Icons.image, color: Colors.white),
                onPressed: pickImage,
              ),
              IconButton(
                icon: const Icon(
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
              IconButton(
                icon: const Icon(Icons.keyboard_hide, color: Colors.white),
                onPressed: () => FocusScope.of(context).unfocus(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
