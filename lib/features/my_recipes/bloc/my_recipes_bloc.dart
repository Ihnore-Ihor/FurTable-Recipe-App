import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/repositories/storage_repository.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_event.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_state.dart';

class MyRecipesBloc extends Bloc<MyRecipesEvent, MyRecipesState> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  final StorageRepository _storageRepo = StorageRepository();
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
    await _recipesSubscription?.cancel();
    emit(MyRecipesLoading());

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const MyRecipesError("User not logged in"));
        return;
      }

      _recipesSubscription = _recipeRepo
          .getMyRecipes(user.uid)
          .listen(
            (allRecipes) {
              final public = allRecipes.where((r) => r.isPublic).toList();
              final private = allRecipes.where((r) => !r.isPublic).toList();
              add(
                MyRecipesUpdated(
                  publicRecipes: public,
                  privateRecipes: private,
                ),
              );
            },
            onError: (error) {
              // Error handling can be added here
            },
          );
    } catch (e) {
      emit(MyRecipesError(e.toString()));
    }
  }

  void _onMyRecipesUpdated(
    MyRecipesUpdated event,
    Emitter<MyRecipesState> emit,
  ) {
    emit(
      MyRecipesLoaded(
        publicRecipes: event.publicRecipes,
        privateRecipes: event.privateRecipes,
      ),
    );
  }

  Future<void> _onDeleteRecipe(
    DeleteRecipeEvent event,
    Emitter<MyRecipesState> emit,
  ) async {
    try {
      // 1. Delete photo from Storage (if exists)
      if (state is MyRecipesLoaded) {
        final currentState = state as MyRecipesLoaded;
        try {
          final recipe = [
            ...currentState.publicRecipes,
            ...currentState.privateRecipes,
          ].firstWhere((r) => r.id == event.recipeId);

          if (recipe.imageUrl.isNotEmpty &&
              recipe.imageUrl.contains('firebasestorage')) {
            await _storageRepo.deleteImage(recipe.imageUrl);
          }
        } catch (_) {
          // If recipe not found or photo error - ignore, main goal is to delete from DB
        }
      }

      // 2. Delete recipe from Firestore (and clean up favorites)
      await _recipeRepo.deleteRecipe(event.recipeId);
    } catch (e) {
      // Could emit failure state if needed
    }
  }

  @override
  Future<void> close() {
    _recipesSubscription?.cancel();
    return super.close();
  }
}
