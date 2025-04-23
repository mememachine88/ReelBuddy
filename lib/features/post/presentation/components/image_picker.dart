import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
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
              Text(
                "All Photos",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
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
                        icon: Icon(
                          Icons.photo_camera,
                          color: Theme.of(context).colorScheme.inversePrimary,
                          size: 28,
                        ),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.camera,
                          );
                          if (picked != null) {
                            final croppedFile = await _cropImage(picked.path);
                            if (croppedFile != null) {
                              final isValid = await _validateImage(
                                File(croppedFile.path),
                              );
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
                              finalImage = await _compressImage(
                                File(croppedFile.path),
                              );
                            }
                          }
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        "TAKE PHOTO",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Theme.of(context).colorScheme.inversePrimary),
              const SizedBox(height: 10),
              Icon(
                Icons.photo_library_outlined,
                size: 60,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    final croppedFile = await _cropImage(picked.path);
                    if (croppedFile != null) {
                      final isValid = await _validateImage(
                        File(croppedFile.path),
                      );
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
                      finalImage = await _compressImage(File(croppedFile.path));
                    }
                  }
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: Text(
                  "Select Image",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
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

  static Future<CroppedFile?> _cropImage(String imagePath) {
    return ImageCropper().cropImage(
      sourcePath: imagePath,
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
  }

  static Future<bool> _validateImage(File file) async {
    if (!await file.exists()) return false;
    if ((await file.length()) > 5 * 1024 * 1024) return false; // >5MB
    final mime = lookupMimeType(file.path);
    if (mime != 'image/jpeg') return false;
    final decoded = img.decodeImage(await file.readAsBytes());
    return decoded != null;
  }

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
