import 'package:firebase_auth/firebase_auth.dart'; // Імпорт
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart';
import 'package:furtable/features/profile/bloc/profile_event.dart';
import 'package:furtable/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final RecipeRepository _recipeRepo = RecipeRepository();

  ProfileBloc() : super(ProfileInitial()) {
    
    // Оновлення нікнейму та аватара
    on<UpdateProfileInfo>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // 1. Оновлюємо Auth профіль
          await user.updateDisplayName(event.nickname);
          // Оновлюємо "посилання" на фото (тут буде наш локальний шлях)
          await user.updatePhotoURL(event.avatarPath);
          
          try {
             await user.reload().timeout(const Duration(seconds: 5));
          } catch (_) {
             // Ігноруємо помилку reload, головне що update пройшов
          }

          // 2. Оновлюємо всі рецепти цього користувача в базі!
          await _recipeRepo.updateAuthorDetails(
            user.uid, 
            event.nickname, 
            event.avatarPath
          );

          emit(const ProfileSuccess("Profile and recipes updated successfully"));
        } else {
          emit(const ProfileFailure("User not logged in"));
        }
      } catch (e) {
        emit(const ProfileFailure("Failed to update profile"));
      }
    });

    // Зміна пароля
    on<ChangePassword>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email != null) {
          // 1. Спочатку треба переавтентифікуватися (вимога безпеки)
          final cred = EmailAuthProvider.credential(
            email: user.email!, 
            password: event.currentPassword
          );
          await user.reauthenticateWithCredential(cred);

          // 2. Тепер міняємо пароль
          await user.updatePassword(event.newPassword);
          emit(const ProfileSuccess("Password changed successfully"));
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
           emit(const ProfileFailure("Incorrect current password"));
        } else {
           emit(ProfileFailure(e.message ?? "Failed to change password"));
        }
      } catch (e) {
        emit(const ProfileFailure("An error occurred"));
      }
    });
  }
}
