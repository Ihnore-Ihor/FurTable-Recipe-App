import 'package:equatable/equatable.dart';

abstract class CreateRecipeEvent extends Equatable {
  const CreateRecipeEvent();
  @override
  List<Object> get props => [];
}

class SubmitRecipe extends CreateRecipeEvent {
  final String title;
  final String description;
  final bool isPublic;

  const SubmitRecipe({
    required this.title,
    required this.description,
    required this.isPublic,
  });

  @override
  List<Object> get props => [title, description, isPublic];
}
