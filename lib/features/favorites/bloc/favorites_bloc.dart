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
  StreamSubscription? _authSubscription;

  /// Creates a [FavoritesBloc].
  FavoritesBloc() : super(FavoritesLoading()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
    on<FavoritesUpdated>(_onFavoritesUpdated);
    on<ClearFavorites>(_onClearFavorites);

    // Initial auth listener to handle reactive loading/clearing
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        add(LoadFavorites());
      } else {
        add(ClearFavorites());
      }
    });
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) async {
    await _favoritesSubscription?.cancel();
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const FavoritesLoaded([]));
      return;
    }

    // We keep the current state (if any) to avoid unnecessary loading flickers.
    // If it's the very first load, FavoritesLoading (from constructor) is already set.

    _favoritesSubscription = _recipeRepo.getFavorites(user.uid).listen(
      (recipes) => add(FavoritesUpdated(recipes)),
      onError: (e) {},
    );
  }

  void _onFavoritesUpdated(FavoritesUpdated event, Emitter<FavoritesState> emit) {
    emit(FavoritesLoaded(event.recipes));
  }

  void _onClearFavorites(ClearFavorites event, Emitter<FavoritesState> emit) {
    _favoritesSubscription?.cancel();
    emit(const FavoritesLoaded([]));
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<FavoritesState> emit) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. OPTIMISTIC UPDATE
    if (state is FavoritesLoaded) {
      final currentRecipes = List<Recipe>.from((state as FavoritesLoaded).recipes);
      final index = currentRecipes.indexWhere((r) => r.id == event.recipe.id);

      if (index >= 0) {
        currentRecipes.removeAt(index);
      } else {
        currentRecipes.add(event.recipe);
      }

      emit(FavoritesLoaded(currentRecipes));
    }

    try {
      // 2. SERVER REQUEST
      await _recipeRepo.toggleFavorite(user.uid, event.recipe);
    } catch (e) {
      // 3. ROLLBACK (re-load from server)
      add(LoadFavorites());
    }
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
