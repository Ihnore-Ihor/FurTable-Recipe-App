import 'package:equatable/equatable.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

abstract class MyRecipesState extends Equatable {
  const MyRecipesState();
  @override
  List<Object> get props => [];
}

class MyRecipesLoading extends MyRecipesState {}

class MyRecipesLoaded extends MyRecipesState {
  final List<Recipe> publicRecipes;
  final List<Recipe> privateRecipes;

  const MyRecipesLoaded({
    required this.publicRecipes,
    required this.privateRecipes,
  });

  @override
  List<Object> get props => [publicRecipes, privateRecipes];
}

class MyRecipesError extends MyRecipesState {
  final String message;
  const MyRecipesError(this.message);
  @override
  List<Object> get props => [message];
}
