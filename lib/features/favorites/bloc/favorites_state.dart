import 'package:equatable/equatable.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

/// Abstract base class for the state of the favorites feature.
abstract class FavoritesState extends Equatable {
  /// Creates a [FavoritesState].
  const FavoritesState();

  @override
  List<Object> get props => [];
}

/// State indicating that favorites are currently loading.
class FavoritesLoading extends FavoritesState {}

/// State indicating that favorites have been successfully loaded.
class FavoritesLoaded extends FavoritesState {
  /// The list of favorite recipes.
  final List<Recipe> recipes;

  /// Creates a [FavoritesLoaded] state.
  const FavoritesLoaded(this.recipes);

  @override
  List<Object> get props => [recipes];
}

/// State indicating that an error occurred while loading favorites.
class FavoritesError extends FavoritesState {
  /// The error message.
  final String message;

  /// Creates a [FavoritesError] state.
  const FavoritesError(this.message);

  @override
  List<Object> get props => [message];
}
