import 'package:equatable/equatable.dart';

/// Abstract base class for search-related events.
abstract class SearchEvent extends Equatable {
  /// Creates a [SearchEvent].
  const SearchEvent();
  @override
  List<Object> get props => [];
}

/// Event triggered when the search query changes.
class SearchQueryChanged extends SearchEvent {
  /// The new search query.
  final String query;

  /// Creates a [SearchQueryChanged] event.
  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}
