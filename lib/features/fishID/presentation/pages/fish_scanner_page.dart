import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/fishID/presentation/cubits/scan_cubit.dart';
import 'package:fyp/features/fishID/presentation/cubits/scan_state.dart';
import 'package:fyp/features/fishID/domain/entities/scan_result.dart';
import 'package:fyp/features/post/presentation/components/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class FishScannerPage extends StatefulWidget {
  final String uid;
  const FishScannerPage({super.key, required this.uid});

  @override
  State<FishScannerPage> createState() => _FishScannerPageState();
}

class _FishScannerPageState extends State<FishScannerPage> {
  File? selectedImage;
  ScanResult? scanResult;

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
      setState(() {
        selectedImage = File(croppedFile.path);
        scanResult = null;
      });
    }
  }

  Future<void> _scanImage() async {
    if (selectedImage != null) {
      context.read<ScanCubit>().scanFish(selectedImage!, widget.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎣 Fish Identifier")),
      body: BlocConsumer<ScanCubit, ScanState>(
        listener: (context, state) {
          if (state is ScanSuccess) {
            setState(() => scanResult = state.result);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 250,
                      color: Colors.grey[200],
                      child:
                          selectedImage != null
                              ? Image.file(selectedImage!, fit: BoxFit.cover)
                              : const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Tap to select image",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (selectedImage != null && state is! ScanLoading)
                  ElevatedButton.icon(
                    onPressed: _scanImage,
                    icon: const Icon(Icons.search),
                    label: const Text("Scan with AI"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),

                if (state is ScanLoading) ...[
                  const SizedBox(height: 30),
                  const Center(child: CircularProgressIndicator()),
                ],

                if (scanResult != null) ...[
                  const SizedBox(height: 30),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "✅ Identification Result",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            "Common Name:",
                            scanResult!.commonName,
                            Icons.pets,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            "Scientific Name:",
                            scanResult!.speciesName,
                            Icons.science,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            "Confidence:",
                            "${(scanResult!.confidence * 100).toStringAsFixed(2)}%",
                            Icons.percent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              children: [
                TextSpan(
                  text: "$label ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
