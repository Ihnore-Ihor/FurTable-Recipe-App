import 'package:equatable/equatable.dart';

/// Abstract base class for search-related events.
abstract class SearchEvent extends Equatable {
  /// Creates a [SearchEvent].
  const SearchEvent();
  @override
  List<Object> get props => [];
}

/// Event triggered to load the search history.
class LoadSearchHistory extends SearchEvent {}

/// Event triggered to clear the search history.
class ClearSearchHistory extends SearchEvent {}

/// Event triggered when the search query changes (live typing).
class SearchQueryChanged extends SearchEvent {
  /// The current query text.
  final String query;

  /// Creates a [SearchQueryChanged] event.
  const SearchQueryChanged(this.query);
  @override
  List<Object> get props => [query];
}

/// Event triggered when the search query is submitted (e.g., pressing Enter).
class SearchQuerySubmitted extends SearchEvent {
  /// The submitted query text.
  final String query;

  /// Creates a [SearchQuerySubmitted] event.
  const SearchQuerySubmitted(this.query);
  @override
  List<Object> get props => [query];
}
