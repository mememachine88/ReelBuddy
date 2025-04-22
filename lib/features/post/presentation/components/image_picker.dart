import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';

class ImagePickerModal {
  static Future<File?> show(BuildContext context) async {
    File? finalImage;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                "All Photos",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.photo_camera,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          // Implement camera support here if needed
                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        "TAKE PHOTO",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          // Video not supported here
                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        "TAKE VIDEO",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),
              const Icon(
                Icons.photo_library_outlined,
                size: 60,
                color: Colors.white54,
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    final original = File(picked.path);
                    final isValid = await _validateImage(original);
                    if (!isValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "❌ Invalid image. Must be JPEG and under 5MB.",
                          ),
                        ),
                      );
                      Navigator.pop(context);
                      return;
                    }

                    final compressed = await _compressImage(original);
                    finalImage = compressed;
                  }
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.tealAccent),
                ),
                child: const Text(
                  "Select Image",
                  style: TextStyle(color: Colors.tealAccent),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );

    return finalImage;
  }

  //Validate: must be JPEG and under 5MB
  static Future<bool> _validateImage(File file) async {
    if (!await file.exists()) return false;
    if ((await file.length()) > 5 * 1024 * 1024) return false;
    final mime = lookupMimeType(file.path);
    if (mime != 'image/jpeg') return false;

    final decoded = img.decodeImage(await file.readAsBytes());
    return decoded != null;
  }

  // Compress image to JPEG with 75% quality
  static Future<File> _compressImage(File file) async {
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
}
