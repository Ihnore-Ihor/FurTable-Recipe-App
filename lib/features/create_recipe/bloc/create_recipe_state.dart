import 'package:equatable/equatable.dart';

/// Abstract base class for all states in the recipe creation flow.
abstract class CreateRecipeState extends Equatable {
  /// Creates a [CreateRecipeState].
  const CreateRecipeState();
  @override
  List<Object> get props => [];
}

/// The initial state of the recipe creation screen.
class CreateRecipeInitial extends CreateRecipeState {}

/// State indicating that the recipe is currently being submitted.
class CreateRecipeLoading extends CreateRecipeState {}

/// State indicating that the recipe was successfully created.
class CreateRecipeSuccess extends CreateRecipeState {}

/// State indicating that an error occurred during recipe creation.
class CreateRecipeFailure extends CreateRecipeState {
  /// The error message.
  final String error;

  /// Creates a [CreateRecipeFailure] with the given error message.
  const CreateRecipeFailure(this.error);
  @override
  List<Object> get props => [error];
}
