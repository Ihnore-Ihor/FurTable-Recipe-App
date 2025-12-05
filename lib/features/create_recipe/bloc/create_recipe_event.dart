import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class CreateRecipeEvent extends Equatable {
  const CreateRecipeEvent();
  @override
  List<Object?> get props => [];
}

class SubmitRecipe extends CreateRecipeEvent {
  final String title;
  final String description;
  final String ingredients;
  final String instructions;
  final int timeMinutes;
  final bool isPublic;
  final Uint8List? imageBytes;

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

// 👇 ОНОВЛЕНИЙ КЛАС UpdateRecipe 👇
class UpdateRecipe extends CreateRecipeEvent {
  final String id;
  final String title;
  final String description;
  final String ingredients;
  final String instructions;
  final int timeMinutes; // <--- ДОДАНО
  final bool isPublic;
  final String? currentImageUrl;
  final Uint8List? newImageBytes;

  const UpdateRecipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.timeMinutes, // <--- ДОДАНО
    required this.isPublic,
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
    currentImageUrl,
    newImageBytes,
  ];
}
