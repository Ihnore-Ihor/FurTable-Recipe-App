import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

class RecipeRepository {
  // Посилання на колекцію 'recipes' у базі Firestore
  final CollectionReference _recipesRef = FirebaseFirestore.instance.collection(
    'recipes',
  );

  // 1. Отримати публічні рецепти (для Explore)
  Stream<List<Recipe>> getPublicRecipes() {
    return _recipesRef
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
        });
  }

  // 2. Отримати мої рецепти (для My Recipes)
  Stream<List<Recipe>> getMyRecipes(String userId) {
    return _recipesRef
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
        });
  }

  // 3. Створити рецепт
  Future<void> createRecipe(Recipe recipe) async {
    await _recipesRef.add(recipe.toFirestore());
  }

  // 4. Оновити рецепт
  Future<void> updateRecipe(Recipe recipe) async {
    await _recipesRef.doc(recipe.id).update(recipe.toFirestore());
  }

  // 5. Видалити рецепт
  Future<void> deleteRecipe(String recipeId) async {
    await _recipesRef.doc(recipeId).delete();
  }
}
