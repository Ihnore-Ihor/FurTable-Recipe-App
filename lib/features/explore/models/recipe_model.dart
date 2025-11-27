import 'package:equatable/equatable.dart';

/// Represents a recipe with its details.
class Recipe extends Equatable {
  /// The unique identifier of the recipe.
  final String id;

  /// The title of the recipe.
  final String title;

  /// The author of the recipe.
  final String author;

  /// The URL or path to the recipe image.
  final String imageUrl;

  /// The number of likes formatted as a string.
  final String likes;

  /// The preparation time in minutes.
  final int timeMinutes;

  /// The list of ingredients required.
  final List<String> ingredients;

  /// The list of cooking steps.
  final List<String> steps;

  /// Creates a [Recipe] instance.
  const Recipe({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.likes,
    required this.timeMinutes,
    required this.ingredients,
    required this.steps,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    imageUrl,
    likes,
    timeMinutes,
    ingredients,
    steps,
  ];
}
