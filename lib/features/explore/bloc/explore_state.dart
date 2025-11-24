import 'package:equatable/equatable.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

enum ExploreStatus { initial, loading, success, failure }

class ExploreState extends Equatable {
  final ExploreStatus status;
  final List<Recipe> recipes;
  final bool hasReachedMax;
  final String errorMessage;

  const ExploreState({
    this.status = ExploreStatus.initial,
    this.recipes = const <Recipe>[],
    this.hasReachedMax = false,
    this.errorMessage = '',
  });

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
