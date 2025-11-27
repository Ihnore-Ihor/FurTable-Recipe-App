import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_event.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_state.dart';

/// Manages the state of the recipe creation process.
///
/// Handles the [SubmitRecipe] event to simulate a network request
/// and validates the input data.
class CreateRecipeBloc extends Bloc<CreateRecipeEvent, CreateRecipeState> {
  /// Creates a [CreateRecipeBloc] with an initial state.
  CreateRecipeBloc() : super(CreateRecipeInitial()) {
    on<SubmitRecipe>((event, emit) async {
      emit(CreateRecipeLoading());
      try {
        // Simulate database write delay.
        await Future.delayed(
          const Duration(seconds: 2),
        );

        // Validate the recipe title.
        if (event.title.isEmpty) {
          emit(const CreateRecipeFailure("Title cannot be empty"));
        } else {
          emit(CreateRecipeSuccess());
        }
      } catch (e) {
        emit(const CreateRecipeFailure("Failed to create recipe"));
      }
    });
  }
}
