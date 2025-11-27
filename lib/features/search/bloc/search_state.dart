import 'package:equatable/equatable.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

/// Abstract base class for the state of the search screen.
abstract class SearchState extends Equatable {
  /// Creates a [SearchState].
  const SearchState();
  @override
  List<Object> get props => [];
}

/// Initial state when no search query has been entered.
class SearchInitial extends SearchState {}

/// State indicating that a search is in progress.
class SearchLoading extends SearchState {}

/// State indicating that recipes were found matching the query.
class SearchSuccess extends SearchState {
  /// The list of matching recipes.
  final List<Recipe> recipes;

  /// Creates a [SearchSuccess] state.
  const SearchSuccess(this.recipes);
  @override
  List<Object> get props => [recipes];
}

/// State indicating that no recipes were found matching the query.
class SearchEmpty extends SearchState {}

/// State indicating that the search history has been loaded.
class SearchHistoryLoaded extends SearchState {
  /// The list of past search queries.
  final List<String> history;

  /// Creates a [SearchHistoryLoaded] state.
  const SearchHistoryLoaded(this.history);
  @override
  List<Object> get props => [history];
}
