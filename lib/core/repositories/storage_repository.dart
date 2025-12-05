import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart'; // <--- Firebase
import 'package:uuid/uuid.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadImageBytes(Uint8List data, String folder) async {
    try {
      final String fileName = '${_uuid.v4()}.jpg';
      final Reference ref = _storage.ref().child('$folder/$fileName');

      final UploadTask uploadTask = ref.putData(
        data,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Firebase Storage upload failed: $e');
    }
  }
}
