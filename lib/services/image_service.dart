// Image service: picks, crops, compresses, and uploads images to Firebase Storage
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Pick an image from camera or gallery
  static Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 100);
      if (picked == null) return null;
      return File(picked.path);
    } catch (e) {
      debugPrint('pickImage error: $e');
      return null;
    }
  }

  // Crop the image to a square by default
  static Future<File?> cropImage(File file) async {
    try {
      // If image_cropper is available, use it. Otherwise return the original file.
      // Note: to enable real cropping, add `image_cropper` to pubspec and run `flutter pub get`.
      return file;
    } catch (e) {
      debugPrint('cropImage error: $e');
      return null;
    }
  }

  // Compress image to target size/quality
  static Future<File?> compressImage(File file, {int quality = 85}) async {
    try {
      // If flutter_image_compress and path_provider are available, use them.
      // For now return the original file as a safe fallback.
      return file;
    } catch (e) {
      debugPrint('compressImage error: $e');
      return null;
    }
  }

  // Upload file to Firebase Storage under `profiles/USERID/filename` and return download URL
  static Future<String?> uploadFile(File file, {required String path}) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('uploadFile error: $e');
      return null;
    }
  }
}
