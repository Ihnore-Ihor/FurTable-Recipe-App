import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/profile/bloc/profile_event.dart';
import 'package:furtable/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<UpdateProfileInfo>((event, emit) async {
      emit(ProfileLoading());
      try {
        await Future.delayed(const Duration(seconds: 2)); // Імітація API
        // Тут логіка: user.updateDisplayName(event.nickname)
        emit(const ProfileSuccess("Profile updated successfully"));
      } catch (e) {
        emit(const ProfileFailure("Failed to update profile"));
      }
    });

    on<ChangePassword>((event, emit) async {
      emit(ProfileLoading());
      try {
        await Future.delayed(const Duration(seconds: 2)); // Імітація API

        if (event.currentPassword == 'wrong') {
          emit(const ProfileFailure("Incorrect current password"));
        } else {
          // Тут логіка: user.updatePassword(event.newPassword)
          emit(const ProfileSuccess("Password changed successfully"));
        }
      } catch (e) {
        emit(const ProfileFailure("Failed to change password"));
      }
    });
  }
}
