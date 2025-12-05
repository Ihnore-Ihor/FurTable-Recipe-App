import 'package:equatable/equatable.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

/// Abstract base class for all events related to the explore feature.
abstract class ExploreEvent extends Equatable {
  /// Creates an [ExploreEvent].
  const ExploreEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered to load recipes, either initially or for pagination.
class LoadRecipesEvent extends ExploreEvent {}

/// Event triggered when recipes are updated from the stream.
class RecipesUpdated extends ExploreEvent {
  /// The list of updated recipes.
  final List<Recipe> recipes;

  /// Creates a [RecipesUpdated] event.
  const RecipesUpdated(this.recipes);

  @override
  List<Object> get props => [recipes];
}
