import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/bloc/explore_event.dart';
import 'package:furtable/features/explore/bloc/explore_state.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart';

/// Manages the state of the Explore screen, including loading recipes.
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  StreamSubscription? _recipesSubscription; // Subscription to the Firestore recipes stream.

  /// Creates an [ExploreBloc] and registers event handlers.
  ExploreBloc() : super(const ExploreState()) {
    on<LoadRecipesEvent>(_onLoadRecipes);
    on<RecipesUpdated>(_onRecipesUpdated);
  }

  Future<void> _onLoadRecipes(
    LoadRecipesEvent event,
    Emitter<ExploreState> emit,
  ) async {
    // If already listening, do nothing
    if (_recipesSubscription != null) return;

    emit(state.copyWith(status: ExploreStatus.loading));

    // Subscribe to the data stream from Firestore
    _recipesSubscription = _recipeRepo.getPublicRecipes().listen(
      (recipes) {
        add(RecipesUpdated(recipes));
      },
      onError: (error) {
        // Handle stream error
        // Firestore Error: $error
      },
    );
  }

  // Handles updates when new data arrives from Firestore.
  void _onRecipesUpdated(RecipesUpdated event, Emitter<ExploreState> emit) {
    emit(
      state.copyWith(
        status: ExploreStatus.success,
        recipes: event.recipes,
        hasReachedMax: true,
      ),
    );
  }

  @override
  Future<void> close() {
    _recipesSubscription?.cancel();
    return super.close();
  }
}
