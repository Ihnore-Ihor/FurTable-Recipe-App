import 'package:equatable/equatable.dart';
import 'package:furtable/features/explore/models/recipe_model.dart'; // <--- ЦЬОГО НЕ ВИСТАЧАЛО

/// Abstract base class for all events related to the explore feature.
abstract class ExploreEvent extends Equatable {
  /// Creates an [ExploreEvent].
  const ExploreEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered to load recipes, either initially or for pagination.
class LoadRecipesEvent extends ExploreEvent {}

class RecipesUpdated extends ExploreEvent {
  final List<Recipe> recipes;
  const RecipesUpdated(this.recipes);
  @override
  List<Object> get props => [recipes];
}
