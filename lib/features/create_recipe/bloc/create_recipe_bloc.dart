import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/repositories/storage_repository.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_event.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_state.dart';
import 'package:furtable/core/utils/avatar_helper.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart';

/// Manages the state of recipe creation and updates.
class CreateRecipeBloc extends Bloc<CreateRecipeEvent, CreateRecipeState> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  final StorageRepository _storageRepo = StorageRepository();

  /// Creates a [CreateRecipeBloc].
  CreateRecipeBloc() : super(CreateRecipeInitial()) {
    on<SubmitRecipe>(_onSubmit);
    on<UpdateRecipe>(_onUpdate);
  }

  /// Handles the recipe submission event.
  Future<void> _onSubmit(
    SubmitRecipe event,
    Emitter<CreateRecipeState> emit,
  ) async {
    emit(CreateRecipeLoading());
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // FORCE refresh to get latest profile updates (name/avatar)
      await user.reload();
      user = FirebaseAuth.instance.currentUser; // Get refreshed user
      if (user == null) throw Exception("User session invalid");

      String imageUrl = '';

      // 1. Upload image to Storage (simulated Supabase/Firebase)
      if (event.imageBytes != null) {
        imageUrl = await _storageRepo.uploadImageBytes(
          event.imageBytes!,
          'recipe_images',
        );
      } else {
        imageUrl = 'https://placehold.co/600x400/png?text=No+Image';
      }

      // 2. Create the recipe object
      final recipe = Recipe(
        id: '', // ID will be assigned by Firestore
        authorId: user.uid,
        authorName: user.displayName ?? 'Chef',
        authorAvatarUrl: user.photoURL ?? AvatarHelper.defaultAvatar,
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

      // 3. Save data to Firestore
      await _recipeRepo.createRecipe(recipe);

      emit(CreateRecipeSuccess());
    } catch (e) {
      emit(CreateRecipeFailure(e.toString()));
    }
  }

  /// Handles the recipe update event.
  Future<void> _onUpdate(
    UpdateRecipe event,
    Emitter<CreateRecipeState> emit,
  ) async {
    emit(CreateRecipeLoading());
    try {
      String imageUrl = event.currentImageUrl ?? '';

      // If user selected a NEW photo
      if (event.newImageBytes != null) {

         // 1. FIRST delete the OLD photo
         // Check if it's a Firebase Storage link (not a placeholder or asset)
         if (imageUrl.isNotEmpty && imageUrl.contains('firebasestorage')) {
            try {
              await _storageRepo.deleteImage(imageUrl);
            } catch (e) {
              // Continue even if old image deletion fails
            }
         }
         
         // 2. THEN upload the NEW photo
         imageUrl = await _storageRepo.uploadImageBytes(event.newImageBytes!, 'recipe_images');
      }

      final user = FirebaseAuth.instance.currentUser;
      
      final recipe = Recipe(
        id: event.id,
        authorId: user?.uid ?? '', 
        authorName: user?.displayName ?? 'Chef',
        title: event.title,
        description: event.description,
        imageUrl: imageUrl, // New or existing URL
        likesCount: 0, // Resetting likes on edit (per requirements)
        timeMinutes: event.timeMinutes,
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
