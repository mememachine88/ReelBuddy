// lib/features/fishID/data/image_validator.dart

import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';

Future<bool> validateFishImage(File file) async {
  if (!await file.exists()) return false;

  final size = await file.length();
  if (size > 5 * 1024 * 1024) return false;

  final mimeType = lookupMimeType(file.path);
  if (mimeType != 'image/jpeg') return false;

  final bytes = await file.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return false;

  if (decoded.width > 4000 || decoded.height > 4000) {
    print("⚠️ Large image (${decoded.width}x${decoded.height})");
  }

  return true;
}
