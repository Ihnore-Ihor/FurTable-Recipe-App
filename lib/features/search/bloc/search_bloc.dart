import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/services/local_storage_service.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart'; // Імпорт
import 'package:furtable/features/search/bloc/search_event.dart';
import 'package:furtable/features/search/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final _storage = LocalStorageService();
  final _recipeRepo = RecipeRepository(); // Репозиторій

  SearchBloc() : super(SearchInitial()) {
    on<LoadSearchHistory>(_onLoadHistory);
    on<ClearSearchHistory>(_onClearHistory);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchQuerySubmitted>(_onQuerySubmitted);
  }

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
    final query = event.query.trim(); // Не робимо toLowerCase тут, репозиторій сам розбереться
    if (query.isEmpty) return;

    await _storage.saveSearchQuery(query);
    emit(SearchLoading());

    try {
      // Викликаємо серверний пошук
      final results = await _recipeRepo.searchRecipes(query);

      // (Опціонально) Якщо хочемо супер-точність, можна додатково відфільтрувати 
      // результати на клієнті, щоб переконатися, що ВСІ слова із запиту є в назві.
      // Але для базового варіанту достатньо результату з бази.

      if (results.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchSuccess(results));
      }
    } catch (e) {
      // У разі помилки мережі
      print("Search Error: $e");
      emit(SearchEmpty());
    }
  }
}
