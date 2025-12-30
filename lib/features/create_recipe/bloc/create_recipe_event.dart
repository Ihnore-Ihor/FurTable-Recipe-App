import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Abstract base class for create recipe events.
abstract class CreateRecipeEvent extends Equatable {
  /// Creates a [CreateRecipeEvent].
  const CreateRecipeEvent();
  @override
  List<Object?> get props => [];
}

/// Event triggered when submitting a new recipe.
class SubmitRecipe extends CreateRecipeEvent {
  final String title;
  final String description;
  final String ingredients;
  final String instructions;
  final int timeMinutes;
  final bool isPublic;
  final Uint8List? imageBytes;

  /// Creates a [SubmitRecipe] event.
  const SubmitRecipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.timeMinutes,
    required this.isPublic,
    this.imageBytes,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    ingredients,
    instructions,
    timeMinutes,
    isPublic,
    imageBytes,
  ];
}

/// Event triggered when updating an existing recipe.
class UpdateRecipe extends CreateRecipeEvent {
  final String id;
  final String title;
  final String description;
  final String ingredients;
  final String instructions;
  final int timeMinutes; // Added field
  final bool isPublic;
  final String? currentImageUrl;
  final Uint8List? newImageBytes;

  final int likesCount;

  /// Creates an [UpdateRecipe] event.
  const UpdateRecipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.timeMinutes, // Added field
    required this.isPublic,
    required this.likesCount,
    this.currentImageUrl,
    this.newImageBytes,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    ingredients,
    instructions,
    timeMinutes,
    isPublic,
    likesCount,
    currentImageUrl,
    newImageBytes,
  ];
}
