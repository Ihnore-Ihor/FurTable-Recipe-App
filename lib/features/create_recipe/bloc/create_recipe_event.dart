import 'package:equatable/equatable.dart';

/// Abstract base class for all events related to creating a recipe.
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
