import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/repositories/storage_repository.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_event.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_state.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart';

class CreateRecipeBloc extends Bloc<CreateRecipeEvent, CreateRecipeState> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  final StorageRepository _storageRepo = StorageRepository();

  CreateRecipeBloc() : super(CreateRecipeInitial()) {
    on<SubmitRecipe>(_onSubmit);
    on<UpdateRecipe>(_onUpdate);
  }

  Future<void> _onSubmit(
    SubmitRecipe event,
    Emitter<CreateRecipeState> emit,
  ) async {
    emit(CreateRecipeLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      String imageUrl = '';

      // 1. Вантажимо картинку в Supabase
      if (event.imageBytes != null) {
        imageUrl = await _storageRepo.uploadImageBytes(
          event.imageBytes!,
          'recipe_images',
        );
      } else {
        imageUrl = 'https://placehold.co/600x400/png?text=No+Image';
      }

      // 2. Створюємо об'єкт рецепту
      final recipe = Recipe(
        id: '', // ID дасть Firestore
        authorId: user.uid,
        authorName: user.displayName ?? 'Chef',
        title: event.title,
        description: event.description,
        imageUrl: imageUrl,
        likesCount: 0,
        timeMinutes: event.timeMinutes,
        ingredients: event.ingredients.split('\n'),
        steps: event.instructions.split('\n'),
        isPublic: event.isPublic,
        createdAt: DateTime.now(),
      );

      // 3. Зберігаємо текст у Firestore
      await _recipeRepo.createRecipe(recipe);

      emit(CreateRecipeSuccess());
    } catch (e) {
      emit(CreateRecipeFailure(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateRecipe event,
    Emitter<CreateRecipeState> emit,
  ) async {
    emit(CreateRecipeLoading());
    try {
      String imageUrl = event.currentImageUrl ?? '';

      if (event.newImageBytes != null) {
        imageUrl = await _storageRepo.uploadImageBytes(
          event.newImageBytes!,
          'recipe_images',
        );
      }

      final user = FirebaseAuth.instance.currentUser;

      final recipe = Recipe(
        id: event.id,
        authorId: user?.uid ?? '',
        authorName: user?.displayName ?? 'Chef',
        title: event.title,
        description: event.description,
        imageUrl: imageUrl,
        likesCount: 0,
        timeMinutes:
            event.timeMinutes, // <--- ВИКОРИСТОВУЄМО НОВЕ ПОЛЕ (було 45)
        ingredients: event.ingredients.split('\n'),
        steps: event.instructions.split('\n'),
        isPublic: event.isPublic,
        createdAt: DateTime.now(),
      );

      await _recipeRepo.updateRecipe(recipe);

      emit(CreateRecipeSuccess());
    } catch (e) {
      emit(CreateRecipeFailure(e.toString()));
    }
  }
}
