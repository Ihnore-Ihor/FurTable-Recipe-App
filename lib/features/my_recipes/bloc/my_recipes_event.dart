import 'package:equatable/equatable.dart';

/// Abstract base class for events related to the user's recipes.
abstract class MyRecipesEvent extends Equatable {
  /// Creates a [MyRecipesEvent].
  const MyRecipesEvent();
  @override
  List<Object> get props => [];
}

/// Event triggered to load the user's recipes.
class LoadMyRecipes extends MyRecipesEvent {}
