import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/core/repositories/storage_repository.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_event.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_state.dart';
import 'package:furtable/core/utils/avatar_helper.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart';
import 'package:furtable/features/profile/repositories/user_repository.dart';

/// Manages the state of recipe creation and updates.
class CreateRecipeBloc extends Bloc<CreateRecipeEvent, CreateRecipeState> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  final StorageRepository _storageRepo = StorageRepository();
  final UserRepository _userRepo = UserRepository();

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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // 1. Fetch the LATEST avatar from Firestore (Source of Truth)
      // This bypasses any local Auth profile caching.
      String currentAvatar = AvatarHelper.defaultAvatar;
      try {
        final fetchedAvatar = await _userRepo.getUserAvatar(user.uid);
        if (fetchedAvatar != null && fetchedAvatar.isNotEmpty) {
          currentAvatar = fetchedAvatar;
        }
      } catch (_) {
        // Fallback to default if fetch fails
      }

      String imageUrl = '';

      // 2. Upload image to Storage
      if (event.imageBytes != null) {
        imageUrl = await _storageRepo.uploadImageBytes(
          event.imageBytes!,
          'recipe_images',
          user.uid,
        );
      } else {
        imageUrl = 'assets/images/haru_eating_en.png';
      }

      // 3. Create the recipe object
      final recipe = Recipe(
        id: '', // ID will be assigned by Firestore
        authorId: user.uid,
        authorName: user.displayName ?? 'Chef',
        authorAvatarUrl: currentAvatar, // <--- Using the fresh one from DB
        title: event.title,
        description: event.description,
        imageUrl: imageUrl,
        likesCount: 0,
        timeMinutes: event.timeMinutes,
        ingredients: event.ingredients.split('\n').where((s) => s.trim().isNotEmpty).toList(),
        steps: event.instructions.split('\n').where((s) => s.trim().isNotEmpty).toList(),
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

  Future<void> _onUpdate(
    UpdateRecipe event,
    Emitter<CreateRecipeState> emit,
  ) async {
    emit(CreateRecipeLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // --- 1. GET LATEST AVATAR (Fix for resetting to default) ---
      String currentAvatar = AvatarHelper.defaultAvatar;
      try {
        final fetchedAvatar = await _userRepo.getUserAvatar(user.uid);
        if (fetchedAvatar != null && fetchedAvatar.isNotEmpty) {
          currentAvatar = fetchedAvatar;
        }
      } catch (_) {
        if (user.photoURL != null) currentAvatar = user.photoURL!;
      }

      // --- 2. Handle Recipe Image ---
      String imageUrl = event.currentImageUrl ?? '';

      // If user selected a NEW photo
      if (event.newImageBytes != null) {
         // FIRST delete the OLD photo
         if (imageUrl.isNotEmpty && imageUrl.contains('firebasestorage')) {
            try { await _storageRepo.deleteImage(imageUrl); } catch (_) {}
         }
         
         // THEN upload the NEW photo
         imageUrl = await _storageRepo.uploadImageBytes(
            event.newImageBytes!, 
            'recipe_images',
            user.uid,
         );
      }
      
      final recipe = Recipe(
        id: event.id,
        authorId: user.uid, 
        authorName: user.displayName ?? 'Chef',
        authorAvatarUrl: currentAvatar, // <--- Using the fresh one
        title: event.title,
        description: event.description,
        imageUrl: imageUrl,
        likesCount: event.likesCount,
        timeMinutes: event.timeMinutes,
        ingredients: event.ingredients.split('\n').where((s) => s.trim().isNotEmpty).toList(),
        steps: event.instructions.split('\n').where((s) => s.trim().isNotEmpty).toList(),
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
