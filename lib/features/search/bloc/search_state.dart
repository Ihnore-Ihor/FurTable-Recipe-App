import 'package:equatable/equatable.dart';
import 'package:furtable/features/explore/models/recipe_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object> get props => [];
}

// Коли користувач ще нічого не ввів
class SearchInitial extends SearchState {}

// Коли йде пошук
class SearchLoading extends SearchState {}

// Коли знайшли рецепти
class SearchSuccess extends SearchState {
  final List<Recipe> recipes;
  const SearchSuccess(this.recipes);
  @override
  List<Object> get props => [recipes];
}

// Коли нічого не знайшли (Empty State з куркою)
class SearchEmpty extends SearchState {}
