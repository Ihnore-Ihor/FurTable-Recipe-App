import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/services/local_storage_service.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/search/bloc/search_event.dart';
import 'package:furtable/features/search/bloc/search_state.dart';

/// Manages the state of the search screen, including query processing, result filtering, and history management.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final _storage = LocalStorageService();

  /// Creates a [SearchBloc] and registers event handlers.
  SearchBloc() : super(SearchInitial()) {
    on<LoadSearchHistory>(_onLoadHistory);
    on<SearchQueryChanged>(_onQueryChanged);
    on<ClearSearchHistory>(_onClearHistory);
    on<SearchQuerySubmitted>(_onQuerySubmitted);
  }

  // Mock list of recipes for search (simulating an API response).
  final List<Recipe> _allRecipes = [
    const Recipe(
      id: '1',
      title: 'Grilled Salmon Teriyaki',
      author: 'ChefMaria',
      imageUrl: 'assets/images/salmon.png',
      likes: '2.4k',
      timeMinutes: 45,
      ingredients: [],
      steps: [],
    ),
    const Recipe(
      id: '2',
      title: 'Creamy Mushroom Pasta',
      author: 'ItalianNonna',
      imageUrl: 'assets/images/pasta.png',
      likes: '1.8k',
      timeMinutes: 30,
      ingredients: [],
      steps: [],
    ),
    const Recipe(
      id: '3',
      title: 'Dragon Roll Sushi',
      author: 'SushiMaster',
      imageUrl: 'assets/images/sushi.png',
      likes: '3.1k',
      timeMinutes: 60,
      ingredients: [],
      steps: [],
    ),
    const Recipe(
      id: '4',
      title: 'Classic Beef Burger',
      author: 'GrillKing',
      imageUrl: 'assets/images/burger.png',
      likes: '956',
      timeMinutes: 25,
      ingredients: [],
      steps: [],
    ),
    const Recipe(
      id: '5',
      title: 'Carrot Cake',
      author: 'SweetTooth',
      imageUrl: 'assets/images/cake.png',
      likes: '4.2k',
      timeMinutes: 50,
      ingredients: [],
      steps: [],
    ),
    const Recipe(
      id: '6',
      title: 'Fresh Garden Salad',
      author: 'HealthyEats',
      imageUrl: 'assets/images/salad.png',
      likes: '1.2k',
      timeMinutes: 15,
      ingredients: [],
      steps: [],
    ),
  ];

  Future<void> _onLoadHistory(
    LoadSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    final history = await _storage.getSearchHistory();
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
    await _storage.clearHistory();
    emit(SearchInitial());
  }

  // 1. WHEN TYPING: Switch between "History" and "Initial State".
  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(LoadSearchHistory());
    } else {
      // If text exists but Enter hasn't been pressed -> show Initial state.
      emit(SearchInitial());
    }
  }

  // 2. WHEN ENTER PRESSED: Save to history + Perform Search.
  Future<void> _onQuerySubmitted(
    SearchQuerySubmitted event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim().toLowerCase();
    if (query.isEmpty) return;

    // A. Save to history.
    await _storage.saveSearchQuery(event.query.trim());

    // B. Start loading.
    emit(SearchLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    // C. Perform search.
    final results = _allRecipes.where((recipe) {
      return recipe.title.toLowerCase().contains(query) ||
          recipe.author.toLowerCase().contains(query);
    }).toList();

    // D. Show results.
    if (results.isEmpty) {
      emit(SearchEmpty());
    } else {
      emit(SearchSuccess(results));
    }
  }
}
