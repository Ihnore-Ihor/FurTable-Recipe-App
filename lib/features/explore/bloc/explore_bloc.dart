import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/bloc/explore_event.dart';
import 'package:furtable/features/explore/bloc/explore_state.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

/// Manages the state of the explore screen, including loading recipes
/// and handling pagination.
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  /// Creates an [ExploreBloc] with an initial state.
  ExploreBloc() : super(const ExploreState()) {
    on<LoadRecipesEvent>(_onLoadRecipes);
  }

  /// Generates a list of mock recipes for testing purposes.
  List<Recipe> _generateMockRecipes(int startIndex, int count) {
    return List.generate(count, (index) {
      final id = startIndex + index;
      final images = [
        'assets/images/salmon.png',
        'assets/images/pasta.png',
        'assets/images/sushi.png',
        'assets/images/burger.png',
        'assets/images/cake.png',
        'assets/images/salad.png',
      ];

      return Recipe(
        id: '$id',
        title: 'Recipe #$id (Tasty Food)',
        author: 'Chef #$id',
        imageUrl: images[id % images.length],
        likes: '${(id * 100) + 50}',
        timeMinutes: 30 + (id % 4) * 10,
        ingredients: ['Ingredient 1', 'Ingredient 2'],
        steps: ['Step 1', 'Step 2'],
      );
    });
  }

  /// Handles the [LoadRecipesEvent] to fetch recipes.
  ///
  /// Supports pagination by appending new recipes to the existing list.
  Future<void> _onLoadRecipes(
    LoadRecipesEvent event,
    Emitter<ExploreState> emit,
  ) async {
    if (state.hasReachedMax) return;

    try {
      if (state.status == ExploreStatus.initial) {
        // Explicitly set the status to loading.
        emit(state.copyWith(status: ExploreStatus.loading));

        await Future.delayed(const Duration(seconds: 1));

        final newRecipes = _generateMockRecipes(0, 10);
        return emit(
          state.copyWith(
            status: ExploreStatus.success,
            recipes: newRecipes,
            hasReachedMax: false,
          ),
        );
      }

      // Logic for loading more recipes (pagination).
      await Future.delayed(const Duration(milliseconds: 800));
      final currentLength = state.recipes.length;
      final moreRecipes = _generateMockRecipes(currentLength, 10);

      if (currentLength >= 40) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            status: ExploreStatus.success,
            recipes: List.of(state.recipes)..addAll(moreRecipes),
            hasReachedMax: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ExploreStatus.failure,
          errorMessage: 'Failed to fetch recipes',
        ),
      );
    }
  }
}
