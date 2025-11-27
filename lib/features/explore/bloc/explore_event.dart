import 'package:equatable/equatable.dart';

/// Abstract base class for all events related to the explore feature.
abstract class ExploreEvent extends Equatable {
  /// Creates an [ExploreEvent].
  const ExploreEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered to load recipes, either initially or for pagination.
class LoadRecipesEvent extends ExploreEvent {}
