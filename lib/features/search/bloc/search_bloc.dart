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
    Recipe(
      id: '1',
      authorId: 'u1',
      authorName: 'ChefMaria',
      title: 'Grilled Salmon Teriyaki',
      description: 'Tasty fish',
      imageUrl: 'assets/images/salmon.png',
      likesCount: 2400,
      timeMinutes: 45,
      ingredients: [],
      steps: [],
      isPublic: true,
      createdAt: DateTime.now(),
    ),
    Recipe(
      id: '2',
      authorId: 'u2',
      title: 'Creamy Mushroom Pasta',
      authorName: 'ItalianNonna',
      description: 'Authentic Italian pasta',
      imageUrl: 'assets/images/pasta.png',
      likesCount: 1800,
      timeMinutes: 30,
      ingredients: [],
      steps: [],
      isPublic: true,
      createdAt: DateTime.now(),
    ),
    Recipe(
      id: '3',
      authorId: 'u3',
      title: 'Dragon Roll Sushi',
      authorName: 'SushiMaster',
      description: 'Fresh sushi roll',
      imageUrl: 'assets/images/sushi.png',
      likesCount: 3100,
      timeMinutes: 60,
      ingredients: [],
      steps: [],
      isPublic: true,
      createdAt: DateTime.now(),
    ),
    Recipe(
      id: '4',
      authorId: 'u4',
      title: 'Classic Beef Burger',
      authorName: 'GrillKing',
      description: 'Juicy beef burger',
      imageUrl: 'assets/images/burger.png',
      likesCount: 956,
      timeMinutes: 25,
      ingredients: [],
      steps: [],
      isPublic: true,
      createdAt: DateTime.now(),
    ),
    Recipe(
      id: '5',
      authorId: 'u5',
      title: 'Carrot Cake',
      authorName: 'SweetTooth',
      description: 'Sweet and moist cake',
      imageUrl: 'assets/images/cake.png',
      likesCount: 4200,
      timeMinutes: 50,
      ingredients: [],
      steps: [],
      isPublic: true,
      createdAt: DateTime.now(),
    ),
    Recipe(
      id: '6',
      authorId: 'u6',
      title: 'Fresh Garden Salad',
      authorName: 'HealthyEats',
      description: 'Crispy and fresh',
      imageUrl: 'assets/images/salad.png',
      likesCount: 1200,
      timeMinutes: 15,
      ingredients: [],
      steps: [],
      isPublic: true,
      createdAt: DateTime.now(),
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
          recipe.authorName.toLowerCase().contains(query);
    }).toList();

    // D. Show results.
    if (results.isEmpty) {
      emit(SearchEmpty());
    } else {
      emit(SearchSuccess(results));
    }
  }
}
