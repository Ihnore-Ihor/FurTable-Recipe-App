import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/search/bloc/search_event.dart';
import 'package:furtable/features/search/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
  }

  // Той самий список для пошуку (в реальності це запит до API)
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

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    // Імітація затримки пошуку
    await Future.delayed(const Duration(milliseconds: 500));

    final results = _allRecipes.where((recipe) {
      final titleLower = recipe.title.toLowerCase();
      final authorLower = recipe.author.toLowerCase();

      return titleLower.contains(query) || authorLower.contains(query);
    }).toList();

    if (results.isEmpty) {
      emit(SearchEmpty());
    } else {
      emit(SearchSuccess(results));
    }
  }
}
