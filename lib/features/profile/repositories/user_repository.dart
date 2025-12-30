import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RecipeRepository _recipeRepo = RecipeRepository();

  // Save or update user data in the 'users' collection
  Future<void> saveUserProfile(String uid, String name, String avatar) async {
    await _firestore.collection('users').doc(uid).set({
      'displayName': name,
      'photoURL': avatar,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge: true to avoid overwriting other fields
  }

  /// Fetches the current user's avatar URL directly from Firestore.
  /// This ensures we have the most up-to-date photo even if the local Auth cache is stale.
  Future<String?> getUserAvatar(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['photoURL'] as String?;
      }
    } catch (e) {
      // Log error if needed, but return null to allow fallback to default avatar
    }
    return null;
  }

  /// Deletes all user-associated data from Firestore.
  /// This includes recipes and the user profile document.
  Future<void> deleteUserData(String uid) async {
    // 1. Find all recipes where the current user is the author
    final recipesSnapshot = await _firestore
        .collection('recipes')
        .where('authorId', isEqualTo: uid)
        .get();

    // 2. Delete each recipe using the repository (handles sub-collections and files)
    for (var doc in recipesSnapshot.docs) {
      await _recipeRepo.deleteRecipe(doc.id);
    }

    // 3. Finally, delete the user profile document
    await _firestore.collection('users').doc(uid).delete();
  }
}
