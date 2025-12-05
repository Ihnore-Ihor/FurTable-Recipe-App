import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart'; // Імпорт
import 'package:furtable/features/favorites/bloc/favorites_event.dart';
import 'package:furtable/features/favorites/bloc/favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  StreamSubscription? _favoritesSubscription;

  FavoritesBloc() : super(FavoritesLoading()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
    on<FavoritesUpdated>(_onFavoritesUpdated); // Нова подія (створимо нижче)
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) async {
    await _favoritesSubscription?.cancel();
    emit(FavoritesLoading());

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const FavoritesError("User not logged in"));
      return;
    }

    _favoritesSubscription = _recipeRepo.getFavorites(user.uid).listen(
      (recipes) => add(FavoritesUpdated(recipes)),
      onError: (e) => print("Favorites Error: $e"),
    );
  }

  void _onFavoritesUpdated(FavoritesUpdated event, Emitter<FavoritesState> emit) {
    emit(FavoritesLoaded(event.recipes));
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<FavoritesState> emit) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ОПТИМІСТИЧНЕ ОНОВЛЕННЯ (Для миттєвої реакції UI)
    // Ми не чекаємо сервера, щоб перефарбувати сердечко.
    // Але оскільки FavoritesBloc керує списком, а не однією карткою, 
    // тут ми просто викликаємо репозиторій. Стрім (getFavorites) сам оновить список, коли сервер підтвердить.
    
    try {
      await _recipeRepo.toggleFavorite(user.uid, event.recipe);
    } catch (e) {
      print("Toggle error: $e");
      // Тут можна показати помилку, якщо транзакція провалилася
    }
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}
