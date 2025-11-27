import 'package:equatable/equatable.dart';

/// Abstract base class for events related to the user's recipes.
abstract class MyRecipesEvent extends Equatable {
  /// Creates a [MyRecipesEvent].
  const MyRecipesEvent();
  @override
  List<Object> get props => [];
}

/// Event triggered to load the user's recipes.
class LoadMyRecipes extends MyRecipesEvent {}

/// Event triggered to delete a recipe.
class DeleteRecipeEvent extends MyRecipesEvent {
  /// The ID of the recipe to delete.
  final String recipeId;

  /// Creates a [DeleteRecipeEvent].
  const DeleteRecipeEvent(this.recipeId);

  @override
  List<Object> get props => [recipeId];
}
