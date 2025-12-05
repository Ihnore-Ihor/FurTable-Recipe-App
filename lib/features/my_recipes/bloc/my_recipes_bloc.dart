import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart'; // <--- Репозиторій
import 'package:furtable/features/my_recipes/bloc/my_recipes_event.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_state.dart';

class MyRecipesBloc extends Bloc<MyRecipesEvent, MyRecipesState> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  StreamSubscription? _recipesSubscription;

  MyRecipesBloc() : super(MyRecipesLoading()) {
    on<LoadMyRecipes>(_onLoadMyRecipes);
    on<MyRecipesUpdated>(_onMyRecipesUpdated);
    on<DeleteRecipeEvent>(_onDeleteRecipe);
  }

  Future<void> _onLoadMyRecipes(
    LoadMyRecipes event,
    Emitter<MyRecipesState> emit,
  ) async {
    // Якщо вже є підписка - скасовуємо стару (на всяк випадок)
    await _recipesSubscription?.cancel();
    
    emit(MyRecipesLoading());

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const MyRecipesError("User not logged in"));
        return;
      }

      // Підписуємося на стрім рецептів ТІЛЬКИ ЦЬОГО користувача
      _recipesSubscription = _recipeRepo.getMyRecipes(user.uid).listen(
        (allRecipes) {
          // Коли приходять дані, ми їх сортуємо
          final public = allRecipes.where((r) => r.isPublic).toList();
          final private = allRecipes.where((r) => !r.isPublic).toList();

          // І відправляємо подію оновлення
          add(MyRecipesUpdated(publicRecipes: public, privateRecipes: private));
        },
        onError: (error) {
          print("MyRecipes Error: $error");
          // Тут важко емітити стан напряму з listen, тому краще обробляти помилки в UI або через окрему подію Error
        },
      );
    } catch (e) {
      emit(MyRecipesError(e.toString()));
    }
  }

  // Обробник оновлення (просто оновлює стан UI)
  void _onMyRecipesUpdated(
    MyRecipesUpdated event,
    Emitter<MyRecipesState> emit,
  ) {
    emit(MyRecipesLoaded(
      publicRecipes: event.publicRecipes,
      privateRecipes: event.privateRecipes,
    ));
  }

  // Видалення (тепер реальне!)
  Future<void> _onDeleteRecipe(
    DeleteRecipeEvent event,
    Emitter<MyRecipesState> emit,
  ) async {
    try {
      // Видаляємо з бази. Стрім вище автоматично побачить зміни і оновить список.
      // Нам НЕ треба вручну правити списки тут.
      await _recipeRepo.deleteRecipe(event.recipeId);
    } catch (e) {
      // Можна додати стан помилки видалення, але для простоти покажемо в консоль
      print("Error deleting: $e");
    }
  }

  @override
  Future<void> close() {
    _recipesSubscription?.cancel();
    return super.close();
  }
}
