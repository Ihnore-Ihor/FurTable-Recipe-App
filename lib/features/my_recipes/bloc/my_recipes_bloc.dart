import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_event.dart';
import 'package:furtable/features/my_recipes/bloc/my_recipes_state.dart';

class MyRecipesBloc extends Bloc<MyRecipesEvent, MyRecipesState> {
  MyRecipesBloc() : super(MyRecipesLoading()) {
    on<LoadMyRecipes>(_onLoadMyRecipes);
  }

  Future<void> _onLoadMyRecipes(
    LoadMyRecipes event,
    Emitter<MyRecipesState> emit,
  ) async {
    emit(MyRecipesLoading());
    try {
      await Future.delayed(const Duration(seconds: 1)); // Імітація мережі

      // Фейкові дані
      final public = [
        const Recipe(
          id: 'mp_1',
          title: 'Homemade Pizza',
          author: 'You',
          imageUrl: 'assets/images/burger.png',
          likes: '124',
          timeMinutes: 40,
          ingredients: [],
          steps: [],
        ),
        const Recipe(
          id: 'mp_2',
          title: 'Banana Bread',
          author: 'You',
          imageUrl: 'assets/images/cake.png',
          likes: '67',
          timeMinutes: 60,
          ingredients: [],
          steps: [],
        ),
      ];

      final private = [
        const Recipe(
          id: 'mpr_1',
          title: 'Secret Family Soup',
          author: 'You',
          imageUrl: 'assets/images/salad.png',
          likes: '0',
          timeMinutes: 120,
          ingredients: [],
          steps: [],
        ),
      ];

      emit(MyRecipesLoaded(publicRecipes: public, privateRecipes: private));
    } catch (e) {
      emit(const MyRecipesError("Failed to load recipes"));
    }
  }
}
