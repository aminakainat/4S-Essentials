import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Private constructor
  StorageService._internal();

  // Singleton instance
  static final StorageService _instance = StorageService._internal();

  // Factory constructor
  factory StorageService() => _instance;

  /// Upload an image to Firebase Storage and return its public download URL
  Future<String> uploadProductImage(XFile imageFile, String fileName) async {
    try {
      // Define path in Firebase Storage bucket
      final Reference ref = _storage.ref().child('products/$fileName');
      
      UploadTask uploadTask;
      if (kIsWeb) {
        // Read as bytes for web
        final Uint8List bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // Use file path for mobile
        uploadTask = ref.putFile(File(imageFile.path));
      }
      
      // Wait for task to finish
      final TaskSnapshot snapshot = await uploadTask;
      
      // Fetch download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }
}
