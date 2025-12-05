import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_event.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_state.dart';

/// Manages the state of the user's recipes.
class MyRecipesBloc extends Bloc<MyRecipesEvent, MyRecipesState> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  StreamSubscription? _recipesSubscription;

  /// Creates a [MyRecipesBloc].
  MyRecipesBloc() : super(MyRecipesLoading()) {
    on<LoadMyRecipes>(_onLoadMyRecipes);
    on<MyRecipesUpdated>(_onMyRecipesUpdated);
    on<DeleteRecipeEvent>(_onDeleteRecipe);
  }

  Future<void> _onLoadMyRecipes(
    LoadMyRecipes event,
    Emitter<MyRecipesState> emit,
  ) async {
    // If a subscription already exists, cancel it.
    await _recipesSubscription?.cancel();
    
    emit(MyRecipesLoading());

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const MyRecipesError("User not logged in"));
        return;
      }

      // Subscribe to the stream of recipes for this user only.
      _recipesSubscription = _recipeRepo.getMyRecipes(user.uid).listen(
        (allRecipes) {
          // Filter recipes when data arrives.
          final public = allRecipes.where((r) => r.isPublic).toList();
          final private = allRecipes.where((r) => !r.isPublic).toList();

          // Dispatch updated event.
          add(MyRecipesUpdated(publicRecipes: public, privateRecipes: private));
        },
        onError: (error) {
          print("MyRecipes Error: $error");
          // Errors from stream are handled here.
        },
      );
    } catch (e) {
      emit(MyRecipesError(e.toString()));
    }
  }

  // Handler for updates (updates UI state).
  void _onMyRecipesUpdated(
    MyRecipesUpdated event,
    Emitter<MyRecipesState> emit,
  ) {
    emit(MyRecipesLoaded(
      publicRecipes: event.publicRecipes,
      privateRecipes: event.privateRecipes,
    ));
  }

  // Handles recipe deletion.
  Future<void> _onDeleteRecipe(
    DeleteRecipeEvent event,
    Emitter<MyRecipesState> emit,
  ) async {
    try {
      // Delete from database. The stream above will automatically detect changes and update the list.
      // We do NOT need to manually update the lists here.
      await _recipeRepo.deleteRecipe(event.recipeId);
    } catch (e) {
      // Error handling for deletion (could emit error state).
      print("Error deleting: $e");
    }
  }

  @override
  Future<void> close() {
    _recipesSubscription?.cancel();
    return super.close();
  }
}
