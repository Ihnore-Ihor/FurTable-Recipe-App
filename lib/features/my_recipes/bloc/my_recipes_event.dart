import 'package:equatable/equatable.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

/// Abstract base class for all events related to the user's recipes.
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

/// Event triggered when updated recipe data is received from the database.
class MyRecipesUpdated extends MyRecipesEvent {
  /// The list of public recipes.
  final List<Recipe> publicRecipes;
  
  /// The list of private recipes.
  final List<Recipe> privateRecipes;

  /// Creates a [MyRecipesUpdated] event.
  const MyRecipesUpdated({
    required this.publicRecipes, 
    required this.privateRecipes
  });

  @override
  List<Object> get props => [publicRecipes, privateRecipes];
}
