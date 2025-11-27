import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_event.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_state.dart';

/// Manages the state of the recipe creation and update process.
///
/// Handles [SubmitRecipe] and [UpdateRecipe] events to simulate network requests
/// and manage the loading/success/failure states.
class CreateRecipeBloc extends Bloc<CreateRecipeEvent, CreateRecipeState> {
  /// Creates a [CreateRecipeBloc] and registers event handlers.
  CreateRecipeBloc() : super(CreateRecipeInitial()) {
    on<SubmitRecipe>(_onSubmit);
    on<UpdateRecipe>(_onUpdate);
  }

  /// Handles the [SubmitRecipe] event.
  Future<void> _onSubmit(
    SubmitRecipe event,
    Emitter<CreateRecipeState> emit,
  ) async {
    emit(CreateRecipeLoading());
    try {
      // Simulate network delay.
      await Future.delayed(const Duration(seconds: 2));
      // Validation is handled in the UI, so we just emit success.
      emit(CreateRecipeSuccess());
    } catch (e) {
      emit(const CreateRecipeFailure("Failed to create recipe"));
    }
  }

  /// Handles the [UpdateRecipe] event.
  Future<void> _onUpdate(
    UpdateRecipe event,
    Emitter<CreateRecipeState> emit,
  ) async {
    emit(CreateRecipeLoading());
    try {
      // Simulate network delay.
      await Future.delayed(const Duration(seconds: 2));
      // Logic to update the recipe in the database would go here.
      emit(CreateRecipeSuccess());
    } catch (e) {
      emit(const CreateRecipeFailure("Failed to update recipe"));
    }
  }
}
