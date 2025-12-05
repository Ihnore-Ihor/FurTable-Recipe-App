import 'package:equatable/equatable.dart';
import 'package:furtable/features/explore/models/recipe_model.dart'; // <--- Імпорт моделі

abstract class MyRecipesEvent extends Equatable {
  const MyRecipesEvent();

  @override
  List<Object> get props => [];
}

class LoadMyRecipes extends MyRecipesEvent {}

class DeleteRecipeEvent extends MyRecipesEvent {
  final String recipeId;
  const DeleteRecipeEvent(this.recipeId);
  @override
  List<Object> get props => [recipeId];
}

// НОВА ПОДІЯ: Прийшли оновлені дані з бази
class MyRecipesUpdated extends MyRecipesEvent {
  final List<Recipe> publicRecipes;
  final List<Recipe> privateRecipes;

  const MyRecipesUpdated({
    required this.publicRecipes, 
    required this.privateRecipes
  });

  @override
  List<Object> get props => [publicRecipes, privateRecipes];
}
