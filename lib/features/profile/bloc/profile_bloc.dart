import 'package:firebase_auth/firebase_auth.dart'; // Імпорт
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/profile/bloc/profile_event.dart';
import 'package:furtable/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    
    // Оновлення нікнейму
    on<UpdateProfileInfo>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(event.nickname);
          
          // user.reload() іноді може "тупити", якщо немає мережі. 
          // Можна пропустити його тут, якщо ми довіряємо updateDisplayName
          // або обгорнути в timeout
          try {
             await user.reload().timeout(const Duration(seconds: 5));
          } catch (_) {
             // Ігноруємо помилку reload, головне що update пройшов
          }

          emit(const ProfileSuccess("Profile updated successfully"));
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
