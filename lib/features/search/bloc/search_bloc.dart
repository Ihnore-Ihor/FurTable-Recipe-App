import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furtable/core/services/local_storage_service.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart';
import 'package:furtable/features/search/bloc/search_event.dart';
import 'package:furtable/features/search/bloc/search_state.dart';

/// Manages the state of the search screen, including history and search results.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final _storage = LocalStorageService();
  final _recipeRepo = RecipeRepository();

  /// Creates a [SearchBloc] and registers event handlers.
  SearchBloc() : super(SearchInitial()) {
    on<LoadSearchHistory>(_onLoadHistory);
    on<ClearSearchHistory>(_onClearHistory);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchQuerySubmitted>(_onQuerySubmitted);
  }

  // Helper to get current User UID
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _onLoadHistory(
    LoadSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    final history = await _storage.getSearchHistory(_currentUserId);
    if (history.isNotEmpty) {
      emit(SearchHistoryLoaded(history));
    } else {
      emit(SearchInitial());
    }
  }

  Future<void> _onClearHistory(
    ClearSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    await _storage.clearHistory(_currentUserId);
    emit(SearchInitial());
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(LoadSearchHistory());
    } else {
      emit(SearchInitial());
    }
  }

  Future<void> _onQuerySubmitted(SearchQuerySubmitted event, Emitter<SearchState> emit) async {
    final query = event.query.trim(); // No toLowerCase here, the repository handles it.
    if (query.isEmpty) return;

    await _storage.saveSearchQuery(query, _currentUserId);
    emit(SearchLoading());

    try {
      // Call server search.
      final results = await _recipeRepo.searchRecipes(query);

      // (Optional) For higher precision, we could filter results on the client
      // to ensure ALL words from the query are in the title.
      // But for this basic implementation, the database result is sufficient.

      if (results.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchSuccess(results));
      }
    } catch (e) {
      // Handle network errors.
      print("Search Error: $e");
      emit(SearchEmpty());
    }
  }
}
