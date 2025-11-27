import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_event.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_state.dart';

/// Manages the state of the user's recipes screen.
///
/// Loads, filters, and deletes recipes.
class MyRecipesBloc extends Bloc<MyRecipesEvent, MyRecipesState> {
  /// Creates a [MyRecipesBloc] and registers event handlers.
  MyRecipesBloc() : super(MyRecipesLoading()) {
    on<LoadMyRecipes>(_onLoadMyRecipes);
    on<DeleteRecipeEvent>(_onDeleteRecipe);
  }

  /// Handles the [LoadMyRecipes] event.
  Future<void> _onLoadMyRecipes(
    LoadMyRecipes event,
    Emitter<MyRecipesState> emit,
  ) async {
    emit(MyRecipesLoading());
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay.

      // Mock data.
      final public = [
        const Recipe(
          id: 'mp_1',
          title: 'Homemade Pizza',
          author: 'You',
          imageUrl: 'assets/images/pizza.png',
          likes: '124',
          timeMinutes: 40,
          ingredients: ['Dough', 'Cheese', 'Tomato'],
          steps: ['Bake it'],
        ),
        const Recipe(
          id: 'mp_2',
          title: 'Banana Bread',
          author: 'You',
          imageUrl: 'assets/images/banana_bread.png',
          likes: '67',
          timeMinutes: 60,
          ingredients: ['Banana', 'Flour'],
          steps: ['Mix and bake'],
        ),
      ];

      final private = [
        const Recipe(
          id: 'mpr_1',
          title: 'Secret Family Soup',
          author: 'You',
          imageUrl: 'assets/images/family_soup.png',
          likes: '0',
          timeMinutes: 120,
          ingredients: ['Secret ingredient'],
          steps: ['Boil it'],
        ),
      ];

      emit(MyRecipesLoaded(publicRecipes: public, privateRecipes: private));
    } catch (e) {
      emit(const MyRecipesError("Failed to load recipes"));
    }
  }

  /// Handles the [DeleteRecipeEvent].
  Future<void> _onDeleteRecipe(
    DeleteRecipeEvent event,
    Emitter<MyRecipesState> emit,
  ) async {
    if (state is MyRecipesLoaded) {
      final currentState = state as MyRecipesLoaded;

      // Create new lists by filtering out the deleted recipe.
      final newPublic = currentState.publicRecipes
          .where((r) => r.id != event.recipeId)
          .toList();

      final newPrivate = currentState.privateRecipes
          .where((r) => r.id != event.recipeId)
          .toList();

      // Emit the updated state.
      emit(
        MyRecipesLoaded(publicRecipes: newPublic, privateRecipes: newPrivate),
      );
    }
  }
}
