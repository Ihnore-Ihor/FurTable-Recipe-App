import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      onError: (e) => print("Favorites Error: $e"),
    );
  }

  void _onFavoritesUpdated(FavoritesUpdated event, Emitter<FavoritesState> emit) {
    emit(FavoritesLoaded(event.recipes));
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<FavoritesState> emit) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // OPTIMISTIC UPDATE (For instant UI reaction)
    // We don't wait for the server to recolor the heart.
    // However, since FavoritesBloc manages the list, not a single card,
    // we simply call the repository here. The stream (getFavorites) will update the list when the server confirms.
    
    try {
      await _recipeRepo.toggleFavorite(user.uid, event.recipe);
    } catch (e) {
      print("Toggle error: $e");
      // Could handle error here if transaction fails.
    }
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}
