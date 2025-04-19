// fishID/presentation/pages/fish_scanner_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/fishID/domain/entities/scan_result.dart';
import 'package:fyp/features/fishID/presentation/cubits/scan_cubit.dart';
import 'package:fyp/features/fishID/presentation/cubits/scan_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fyp/features/fishID/data/service/image_validator.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FishScannerPage extends StatefulWidget {
  final String uid; // current user ID

  const FishScannerPage({super.key, required this.uid});

  @override
  State<FishScannerPage> createState() => _FishScannerPageState();
}

class _FishScannerPageState extends State<FishScannerPage> {
  File? selectedImage;

  // Pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image != null) {
      final originalFile = File(image.path);
      final isValid = await validateFishImage(originalFile);

      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Invalid image. Must be JPEG and under 5MB."),
          ),
        );
        return;
      }

      // Compress if needed
      File fileToUpload = originalFile;
      final size = await originalFile.length();
      if (size > 5 * 1024 * 1024) {
        fileToUpload = await compressImage(originalFile);
        print("📦 Image compressed before upload");
      }

      if (!fileToUpload.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Selected image is corrupted or missing."),
          ),
        );
        return;
      }
      // ✅ show live preview
      context.read<ScanCubit>().scanFish(fileToUpload, widget.uid);
    }
  }

  // Compress image method
  Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
      format: CompressFormat.jpeg,
    );

    return result != null ? File(result.path) : file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎣 Fish Identifier')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BlocBuilder<ScanCubit, ScanState>(
          builder: (context, state) {
            if (state is ScanLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ScanError) {
              return Center(
                child: Text(
                  "❌ Error: ${state.message}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state is ScanSuccess) {
              return SingleChildScrollView(child: _buildResult(state.result));
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Upload or take a photo of a fish",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Pick from Gallery"),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take a Photo"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Build scanned result UI
  Widget _buildResult(ScanResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "✅ Fish Identified:",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text("Species: ${result.speciesName}"),
        Text("Confidence: ${(result.confidence * 100).toStringAsFixed(2)}%"),
        const SizedBox(height: 20),
        if (selectedImage != null && selectedImage!.path.isNotEmpty)
          Image.file(selectedImage!, height: 300, fit: BoxFit.cover)
        else
          const Text("❗ Image preview not available"),

        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              selectedImage = null;
              context.read<ScanCubit>().reset();
            });
          },
          icon: const Icon(Icons.restart_alt),
          label: const Text("Scan Another"),
        ),
      ],
    );
  }
}
