import 'dart:io';

abstract class StorageRepo {
  //upload profile image
  Future<String?> uploadProfileImage(String path, String fileName);

  //upload post pictures
  Future<String?> uploadPostImage(String path, String fileName);
}
