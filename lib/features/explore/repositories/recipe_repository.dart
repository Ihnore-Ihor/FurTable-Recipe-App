import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Deletes a recipe.
  Future<void> deleteRecipe(String recipeId) async {
    await _recipesRef.doc(recipeId).delete();
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

  /// Toggles the favorite status of a recipe using a transaction.
  Future<void> toggleFavorite(String userId, Recipe recipe) async {
    final userFavRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipe.id);

    final recipeRef = _recipesRef.doc(recipe.id);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      // 1. Check if user already liked this recipe
      final snapshot = await transaction.get(userFavRef);

      if (snapshot.exists) {
        // --- IF LIKED -> REMOVE ---
        transaction.delete(userFavRef);
        transaction.update(recipeRef, {
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // --- IF NOT LIKED -> ADD ---
        // Add +1 to local model before saving to favorites,
        // so favorites immediately show the correct count.
        final recipeToSave = Recipe(
          id: recipe.id,
          authorId: recipe.authorId,
          authorName: recipe.authorName,
          authorAvatarUrl: recipe.authorAvatarUrl, // Save avatar
          title: recipe.title,
          description: recipe.description,
          imageUrl: recipe.imageUrl,
          likesCount: recipe.likesCount + 1, // +1 for profile display
          timeMinutes: recipe.timeMinutes,
          ingredients: recipe.ingredients,
          steps: recipe.steps,
          isPublic: recipe.isPublic,
          createdAt: recipe.createdAt,
        );

        transaction.set(userFavRef, recipeToSave.toFirestore());
        transaction.update(recipeRef, {
          'likesCount': FieldValue.increment(1),
        });
      }
    });
  }

  /// Batch updates author details in all their recipes.
  Future<void> updateAuthorDetails(
      String userId, String newName, String newAvatar) async {
    // 2. Create a batch for atomic update
    final batch = FirebaseFirestore.instance.batch();

    // A. Update in main 'recipes' collection
    final mainSnapshot =
        await _recipesRef.where('authorId', isEqualTo: userId).get();

    for (var doc in mainSnapshot.docs) {
      batch.update(doc.reference, {
        'authorName': newName,
        'authorAvatarUrl': newAvatar,
        // Update search keywords because name changed!
        'searchKeywords': Recipe.generateKeywords(doc['title'], newName),
      });
    }

    // B. Update in 'users/{userId}/favorites' (User's favorites)
    // This fixes bug where "Favorites" keeps old nickname/photo
    final favSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .where('authorId', isEqualTo: userId) // Find only own recipes in favorites
        .get();

    for (var doc in favSnapshot.docs) {
      batch.update(doc.reference, {
        'authorName': newName,
        'authorAvatarUrl': newAvatar,
        // searchKeywords usually not needed in favorites, but can update
      });
    }

    // 3. Commit changes
    await batch.commit();
  }

  /// Gets the list of favorite recipes (Stream).
  Stream<List<Recipe>> getFavorites(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
    });
  }
}
