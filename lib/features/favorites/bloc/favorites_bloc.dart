import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/favorites/bloc/favorites_event.dart';
import 'package:furtable/features/favorites/bloc/favorites_state.dart';

/// Manages the state of the favorites feature, including loading and toggling favorites.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  /// Creates a [FavoritesBloc] with an initial loading state.
  FavoritesBloc() : super(FavoritesLoading()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  // Initial list of favorites (simulating a database).
  List<Recipe> _currentFavorites = [
    const Recipe(
      id: '1',
      title: 'Grilled Salmon Teriyaki',
      author: 'ChefMaria',
      imageUrl: 'assets/images/salmon.png',
      likes: '2.4k',
      timeMinutes: 45,
      ingredients: ['Salmon', 'Soy Sauce'],
      steps: ['Cook it'],
    ),
    const Recipe(
      id: '3',
      title: 'Dragon Roll Sushi',
      author: 'SushiMaster',
      imageUrl: 'assets/images/sushi.png',
      likes: '3.1k',
      timeMinutes: 60,
      ingredients: ['Rice', 'Fish'],
      steps: ['Roll it'],
    ),
  ];

  /// Handles the [LoadFavorites] event to fetch the list of favorite recipes.
  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      // Simulate network delay.
      await Future.delayed(const Duration(milliseconds: 800));
      emit(FavoritesLoaded(List.from(_currentFavorites)));
    } catch (e) {
      emit(const FavoritesError("Failed to load favorites"));
    }
  }

  /// Handles the [ToggleFavorite] event to add or remove a recipe from favorites.
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    if (state is FavoritesLoaded) {
      final currentList = (state as FavoritesLoaded).recipes;
      final exists = currentList.any((r) => r.id == event.recipe.id);

      List<Recipe> newList;
      if (exists) {
        // Remove from favorites.
        newList = currentList.where((r) => r.id != event.recipe.id).toList();
      } else {
        // Add to favorites.
        newList = List.from(currentList)..add(event.recipe);
      }

      // Update local cache.
      _currentFavorites = newList;

      // Emit new state.
      emit(FavoritesLoaded(newList));
    }
  }
}
