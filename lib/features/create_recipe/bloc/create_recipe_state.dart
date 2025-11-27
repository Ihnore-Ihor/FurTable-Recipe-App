import 'package:equatable/equatable.dart';

abstract class CreateRecipeState extends Equatable {
  const CreateRecipeState();
  @override
  List<Object> get props => [];
}

class CreateRecipeInitial extends CreateRecipeState {}

class CreateRecipeLoading extends CreateRecipeState {}

class CreateRecipeSuccess extends CreateRecipeState {}

class CreateRecipeFailure extends CreateRecipeState {
  final String error;
  const CreateRecipeFailure(this.error);
  @override
  List<Object> get props => [error];
}
