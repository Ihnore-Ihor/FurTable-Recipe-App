import 'package:equatable/equatable.dart';

abstract class MyRecipesEvent extends Equatable {
  const MyRecipesEvent();
  @override
  List<Object> get props => [];
}

class LoadMyRecipes extends MyRecipesEvent {}
