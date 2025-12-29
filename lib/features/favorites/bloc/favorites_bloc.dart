import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart';
import 'package:furtable/features/favorites/bloc/favorites_event.dart';
import 'package:furtable/features/favorites/bloc/favorites_state.dart';

/// Manages the state of the user's favorite recipes.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  StreamSubscription? _favoritesSubscription;

  /// Creates a [FavoritesBloc].
  FavoritesBloc() : super(FavoritesLoading()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
    on<FavoritesUpdated>(_onFavoritesUpdated);
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) async {
    await _favoritesSubscription?.cancel();
    emit(FavoritesLoading());

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const FavoritesError("User not logged in"));
      return;
    }

    _favoritesSubscription = _recipeRepo.getFavorites(user.uid).listen(
      (recipes) => add(FavoritesUpdated(recipes)),
      onError: (e) {}, // Favorites Error
    );
  }

  void _onFavoritesUpdated(FavoritesUpdated event, Emitter<FavoritesState> emit) {
    emit(FavoritesLoaded(event.recipes));
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<FavoritesState> emit) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. OPTIMISTIC UPDATE
    // We take the current list and IMMEDIATELY change it in the UI
    if (state is FavoritesLoaded) {
      final currentRecipes = List<Recipe>.from((state as FavoritesLoaded).recipes);
      final isExist = currentRecipes.any((r) => r.id == event.recipe.id);

      if (isExist) {
        currentRecipes.removeWhere((r) => r.id == event.recipe.id);
      } else {
        currentRecipes.add(event.recipe);
      }

      // Emit updated state immediately (before server request)
      emit(FavoritesLoaded(currentRecipes));
    }

    try {
      // 2. SERVER REQUEST (in background)
      await _recipeRepo.toggleFavorite(user.uid, event.recipe);
      
      // We no longer call add(LoadFavorites()) because we already updated locally,
      // and the StreamSubscription in _onLoadFavorites will sync the server truth later.

    } catch (e) {
      print("!!! FAVORITE TOGGLE ERROR: $e");
      // 3. ROLLBACK (on error)
      // If the server rejected the request, just reload everything
      add(LoadFavorites());
    }
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}
