import 'package:equatable/equatable.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

/// Abstract base class for all events related to favorites.
abstract class FavoritesEvent extends Equatable {
  /// Creates a [FavoritesEvent].
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered to load the list of favorite recipes.
class LoadFavorites extends FavoritesEvent {}

/// Event triggered to toggle the favorite status of a recipe.
class ToggleFavorite extends FavoritesEvent {
  /// The recipe to toggle.
  final Recipe recipe;

  /// Creates a [ToggleFavorite] event.
  const ToggleFavorite(this.recipe);

  @override
  List<Object> get props => [recipe];
}
