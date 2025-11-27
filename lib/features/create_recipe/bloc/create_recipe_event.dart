import 'package:equatable/equatable.dart';

/// Abstract base class for all events related to creating or updating a recipe.
abstract class CreateRecipeEvent extends Equatable {
  /// Creates a [CreateRecipeEvent].
  const CreateRecipeEvent();
  @override
  List<Object> get props => [];
}

/// Event triggered when the user submits a new recipe.
class SubmitRecipe extends CreateRecipeEvent {
  /// The title of the recipe.
  final String title;

  /// The description of the recipe.
  final String description;

  /// Whether the recipe is visible to the public.
  final bool isPublic;

  /// Creates a [SubmitRecipe] event.
  const SubmitRecipe({
    required this.title,
    required this.description,
    required this.isPublic,
  });

  @override
  List<Object> get props => [title, description, isPublic];
}

/// Event triggered when the user updates an existing recipe.
class UpdateRecipe extends CreateRecipeEvent {
  /// The ID of the recipe being updated.
  final String id;

  /// The new title of the recipe.
  final String title;

  /// The new description of the recipe.
  final String description;

  /// The new visibility status of the recipe.
  final bool isPublic;

  /// Creates an [UpdateRecipe] event.
  const UpdateRecipe({
    required this.id,
    required this.title,
    required this.description,
    required this.isPublic,
  });

  @override
  List<Object> get props => [id, title, description, isPublic];
}
