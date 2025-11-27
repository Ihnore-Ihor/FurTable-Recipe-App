import 'package:equatable/equatable.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

/// Enum representing the possible statuses of the explore screen.
enum ExploreStatus { initial, loading, success, failure }

/// Represents the state of the explore screen.
///
/// Contains the list of recipes, the current status, and pagination info.
class ExploreState extends Equatable {
  /// The current status of the data loading.
  final ExploreStatus status;

  /// The list of loaded recipes.
  final List<Recipe> recipes;

  /// Whether the end of the list has been reached.
  final bool hasReachedMax;

  /// An error message if the status is [ExploreStatus.failure].
  final String errorMessage;

  /// Creates an [ExploreState].
  const ExploreState({
    this.status = ExploreStatus.initial,
    this.recipes = const <Recipe>[],
    this.hasReachedMax = false,
    this.errorMessage = '',
  });

  /// Creates a copy of this state with the given fields replaced with new values.
  ExploreState copyWith({
    ExploreStatus? status,
    List<Recipe>? recipes,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return ExploreState(
      status: status ?? this.status,
      recipes: recipes ?? this.recipes,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, recipes, hasReachedMax, errorMessage];
}
