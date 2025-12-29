import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Repository for handling user feedback submission to Firestore.
class FeedbackRepository {
  final _db = FirebaseFirestore.instance;

  /// Sends the user's feedback to the 'feedback' collection in Firestore.
  /// 
  /// Includes user details (id, email) if available, or 'anonymous' if not.
  Future<void> sendFeedback(String message) async {
    final user = FirebaseAuth.instance.currentUser;
    
    await _db.collection('feedback').add({
      'message': message,
      'userId': user?.uid ?? 'anonymous',
      'email': user?.email ?? 'anonymous',
      'timestamp': FieldValue.serverTimestamp(),
      'platform': 'web', // Can be made dynamic if needed
    });
  }
}
