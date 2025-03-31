import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fyp/features/storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Future<String?> uploadProfileImage(String path, String fileName) {
    return _uploadFile(path, fileName, "profile_images"); // Example folder name
  }

  /* 

  Helper methods 

  */

  //upload file
  Future<String?> _uploadFile(
    String path,
    String fileName,
    String folder,
  ) async {
    try {
      // Get file
      final file = File(path);

      // Find place to store
      final storageRef = storage.ref().child('$folder/$fileName');

      // Upload
      final uploadTask = await storageRef.putFile(file);

      // Get image download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Return the download URL
      return downloadUrl;
    } catch (e) {
      print("Error uploading file: $e");
      return null; // Return null in case of an error
    }
  }

  //upload posts
  @override
  Future<String?> uploadPostImage(String path, String fileName) {
    return _uploadFile(path, fileName, "post_images");
  }
}
