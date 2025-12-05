import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/bloc/explore_event.dart';
import 'package:furtable/features/explore/bloc/explore_state.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  StreamSubscription? _recipesSubscription; // Щоб слухати базу

  ExploreBloc() : super(const ExploreState()) {
    on<LoadRecipesEvent>(_onLoadRecipes);
    on<RecipesUpdated>(_onRecipesUpdated); // Нова внутрішня подія
  }

  Future<void> _onLoadRecipes(
    LoadRecipesEvent event,
    Emitter<ExploreState> emit,
  ) async {
    // Якщо вже слухаємо - нічого не робити
    if (_recipesSubscription != null) return;

    emit(state.copyWith(status: ExploreStatus.loading));

    // Підписуємося на потік даних з Firestore
    _recipesSubscription = _recipeRepo.getPublicRecipes().listen(
      (recipes) {
        add(RecipesUpdated(recipes));
      },
      onError: (error) {
        // Обробка помилки в потоці
        print("Firestore Error: $error");
      },
    );
  }

  // Коли приходять нові дані з бази -> оновлюємо UI
  void _onRecipesUpdated(RecipesUpdated event, Emitter<ExploreState> emit) {
    emit(
      state.copyWith(
        status: ExploreStatus.success,
        recipes: event.recipes,
        hasReachedMax: true, // Для простоти (без пагінації)
      ),
    );
  }

  @override
  Future<void> close() {
    _recipesSubscription?.cancel();
    return super.close();
  }
}
