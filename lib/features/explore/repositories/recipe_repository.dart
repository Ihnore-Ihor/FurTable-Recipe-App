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

  // 6. Реальний пошук на сервері
  Future<List<Recipe>> searchRecipes(String query) async {
    // Очищаємо запит і беремо перше слово (Firestore array-contains шукає тільки одне значення за раз)
    // Це обмеження безкоштовного рішення, але для лаби достатньо.
    final cleanQuery = query.toLowerCase().trim().split(' ').first; 

    if (cleanQuery.isEmpty) return [];

    final snapshot = await _recipesRef
        .where('isPublic', isEqualTo: true)
        // Магія тут: шукаємо, чи містить масив 'searchKeywords' наше слово
        .where('searchKeywords', arrayContains: cleanQuery) 
        .get();
        
    return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
  }

  // ЄДИНИЙ МЕТОД ДЛЯ ЛАЙКІВ (Транзакція)
  Future<void> toggleFavorite(String userId, Recipe recipe) async {
    final userFavRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipe.id);

    final recipeRef = _recipesRef.doc(recipe.id);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      // 1. Перевіряємо, чи лайкнув цей юзер цей рецепт раніше
      final snapshot = await transaction.get(userFavRef);

      if (snapshot.exists) {
        // --- ЯКЩО ЛАЙК Є -> ВИДАЛЯЄМО ---
        transaction.delete(userFavRef);
        transaction.update(recipeRef, {
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // --- ЯКЩО ЛАЙКА НЕМАЄ -> ДОДАЄМО ---
        // Додаємо +1 до локальної моделі перед збереженням в favorites,
        // щоб в закладках зразу була правильна цифра
        final recipeToSave = Recipe(
          id: recipe.id,
          authorId: recipe.authorId,
          authorName: recipe.authorName,
          title: recipe.title,
          description: recipe.description,
          imageUrl: recipe.imageUrl,
          likesCount: recipe.likesCount + 1, // +1 для відображення в профілі
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

  // 9. Отримати список улюблених (Stream)
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
