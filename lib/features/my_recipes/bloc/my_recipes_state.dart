import 'package:equatable/equatable.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

/// Abstract base class for the state of the user's recipes screen.
abstract class MyRecipesState extends Equatable {
  /// Creates a [MyRecipesState].
  const MyRecipesState();
  @override
  List<Object> get props => [];
}

/// State indicating that recipes are currently loading.
class MyRecipesLoading extends MyRecipesState {}

/// State indicating that recipes have been successfully loaded.
class MyRecipesLoaded extends MyRecipesState {
  /// List of public recipes created by the user.
  final List<Recipe> publicRecipes;

  /// List of private recipes created by the user.
  final List<Recipe> privateRecipes;

  /// Creates a [MyRecipesLoaded] state with the given recipes.
  const MyRecipesLoaded({
    required this.publicRecipes,
    required this.privateRecipes,
  });

  @override
  List<Object> get props => [publicRecipes, privateRecipes];
}

/// State indicating that an error occurred while loading recipes.
class MyRecipesError extends MyRecipesState {
  /// The error message.
  final String message;

  /// Creates a [MyRecipesError] with the given message.
  const MyRecipesError(this.message);
  @override
  List<Object> get props => [message];
}
