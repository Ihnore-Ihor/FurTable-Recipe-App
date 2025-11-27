import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_event.dart';
import 'package:furtable/features/create_recipe/bloc/create_recipe_state.dart';

class CreateRecipeBloc extends Bloc<CreateRecipeEvent, CreateRecipeState> {
  CreateRecipeBloc() : super(CreateRecipeInitial()) {
    on<SubmitRecipe>((event, emit) async {
      emit(CreateRecipeLoading());
      try {
        await Future.delayed(
          const Duration(seconds: 2),
        ); // Імітація запису в БД

        // Тут могла б бути валідація, наприклад:
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
