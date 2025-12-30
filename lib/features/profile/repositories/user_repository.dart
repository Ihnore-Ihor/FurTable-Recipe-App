import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save or update user data in the 'users' collection
  Future<void> saveUserProfile(String uid, String name, String avatar) async {
    await _firestore.collection('users').doc(uid).set({
      'displayName': name,
      'photoURL': avatar,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge: true to avoid overwriting other fields
  }
}
