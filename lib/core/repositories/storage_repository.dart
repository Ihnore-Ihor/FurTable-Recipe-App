import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Repository for handling file storage operations, such as uploading images.
class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Uploads image bytes to Firebase Storage and returns the download URL.
  ///
  /// [data] is the image content in bytes.
  /// [folder] is the storage path where the image should be saved.
  /// [userId] is the ID of the file owner (for security rules).
  /// Throws an [Exception] if the upload fails.
  Future<String> uploadImageBytes(Uint8List data, String folder, String userId) async {
    try {
      // 1. Change extension to .webp
      final String fileName = '${_uuid.v4()}.webp'; 
      final Reference ref = _storage.ref().child('$folder/$fileName');

      final metadata = SettableMetadata(
        contentType: 'image/webp', // <--- Tell browser it's WebP
        customMetadata: {
          'owner': userId,
        },
      );

      final UploadTask uploadTask = ref.putData(data, metadata);

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Firebase Storage upload failed: $e');
    }
  }

  /// Deletes an image from Firebase Storage using its URL.
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Firebase can find the file ref from its full download URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors (e.g., file already deleted or broken URL) 
      // to avoid blocking the main recipe deletion process.
    }
  }
}
