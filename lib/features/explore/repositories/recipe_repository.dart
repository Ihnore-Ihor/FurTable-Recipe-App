import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:furtable/features/explore/models/recipe_model.dart';

/// Repository for handling recipe-related operations in Firestore.
class RecipeRepository {
  // Reference to the 'recipes' collection in Firestore
  final CollectionReference _recipesRef = FirebaseFirestore.instance.collection(
    'recipes',
  );

  /// Gets public recipes (for Explore screen).
  Stream<List<Recipe>> getPublicRecipes() {
    return _recipesRef
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
        });
  }

  /// Gets recipes authored by a specific user (for My Recipes).
  Stream<List<Recipe>> getMyRecipes(String userId) {
    return _recipesRef
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
        });
  }

  /// Creates a new recipe.
  Future<void> createRecipe(Recipe recipe) async {
    await _recipesRef.add(recipe.toFirestore());
  }

  /// Updates an existing recipe.
  Future<void> updateRecipe(Recipe recipe) async {
    await _recipesRef.doc(recipe.id).update(recipe.toFirestore());
  }

  /// Deletes a recipe and removes it from all users' favorites.
  Future<void> deleteRecipe(String recipeId) async {
    final batch = FirebaseFirestore.instance.batch();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) throw Exception("User not logged in");

    try {
      // 1. Delete favorites (Collection Group)
      final favoritesGroup = FirebaseFirestore.instance.collectionGroup('favorites');
      
      // IMPORTANT: We add filter by authorId.
      // This satisfies security rules effectively asking only for docs where WE are the author.
      final snapshots = await favoritesGroup
          .where('recipeId', isEqualTo: recipeId)
          .where('authorId', isEqualTo: user.uid) // <--- ADDED THIS
          .get();

      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
    } catch (e) {
      debugPrint("Warning: Could not cleanup favorites: $e");
      // Don't rethrow, ensure we at least delete the recipe itself
    }

    // 2. Delete the recipe itself
    final recipeRef = _recipesRef.doc(recipeId);
    batch.delete(recipeRef);

    // 3. Commit
    await batch.commit();
  }

  /// Performs a search for recipes on the server.
  Future<List<Recipe>> searchRecipes(String query) async {
    // Clean query and take the first word (Firestore array-contains searches only one value at a time).
    // This is a limitation of the free solution, but sufficient for this lab.
    final cleanQuery = query.toLowerCase().trim().split(' ').first;

    if (cleanQuery.isEmpty) return [];

    final snapshot = await _recipesRef
        .where('isPublic', isEqualTo: true)
        // Magic here: check if the 'searchKeywords' array contains our word
        .where('searchKeywords', arrayContains: cleanQuery)
        .get();

    return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
  }

  /// Toggles the favorite status of a recipe within a transaction.
  ///
  /// Stores only the reference (ID and addedAt) in the user's subcollection.
  Future<void> toggleFavorite(String userId, Recipe recipe) async {
    final userFavRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipe.id);

    final recipeRef = _recipesRef.doc(recipe.id);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final userFavSnapshot = await transaction.get(userFavRef);
      // 1. Read main recipe state (to check existence and update count)
      final recipeSnapshot = await transaction.get(recipeRef);

      if (userFavSnapshot.exists) {
        // --- REMOVE FROM FAVORITES ---
        
        transaction.delete(userFavRef);

        // Decrease counter ONLY IF recipe still exists
        if (recipeSnapshot.exists) {
          transaction.update(recipeRef, {
            'likesCount': FieldValue.increment(-1),
          });
        }
      } else {
        // --- ADD TO FAVORITES ---
        
        // If main recipe doesn't exist, we can't like it
        if (!recipeSnapshot.exists) {
          throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'not-found',
              message: 'Recipe no longer exists');
        }

        // Save ONLY minimal data (ID and addedAt)
        transaction.set(userFavRef, {
          'addedAt': FieldValue.serverTimestamp(),
          'recipeId': recipe.id,
          'authorId': recipe.authorId, // Used for security rules (cascading delete)
        });

        transaction.update(recipeRef, {
          'likesCount': FieldValue.increment(1),
        });
      }
    });
  }

  // --- CASCADING UPDATE: User Profile Changes ---
  Future<void> updateAuthorDetails(String userId, String newName, String newAvatar) async {
    // 1. Find all recipes by this author
    final snapshot = await _recipesRef.where('authorId', isEqualTo: userId).get();
    
    if (snapshot.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final title = data['title'] as String;

      batch.update(doc.reference, {
        'authorName': newName,
        'authorAvatarUrl': newAvatar,
        // Update keywords because the author name is part of the search index
        'searchKeywords': _generateKeywordsForUpdate(title, newName),
      });
    }

    // 2. Commit all updates atomically
    await batch.commit();
  }

  // Helper to generate keywords (duplicated from Model to avoid circular deps or static constraints)
  List<String> _generateKeywordsForUpdate(String title, String author) {
    Set<String> keywords = {};
    final words = "$title $author".toLowerCase().split(' ');
    for (var word in words) {
      String temp = "";
      for (int i = 0; i < word.length; i++) {
        temp += word[i];
        keywords.add(temp);
      }
    }
    return keywords.toList();
  }

  /// Gets the list of favorite recipes by fetching full documents from references.
  Stream<List<Recipe>> getFavorites(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          // 1. Get all IDs from the favorites collection
          final ids = snapshot.docs.map((doc) => doc.id).toList();
          
          if (ids.isEmpty) return [];

          // 2. Fetch recipes from the main collection using the IDs.
          // Firestore 'whereIn' supports up to 30 items (FieldPath.documentId).
          // For a production app, we would chunk this. For this lab, 30 is fine.
          
          // Note: 'whereIn' doesn't guarantee order, so we might need to sort client-side 
          // if strict 'addedAt' order is required.
          
          final recipesQuery = await _recipesRef
              .where(FieldPath.documentId, whereIn: ids)
              .get();

          return recipesQuery.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
        });
  }
}
