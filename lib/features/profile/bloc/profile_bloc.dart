import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/profile/bloc/profile_event.dart';
import 'package:furtable/features/profile/bloc/profile_state.dart';

/// Manages the state of the user profile, including updating info and changing passwords.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  /// Creates a [ProfileBloc].
  ProfileBloc() : super(ProfileInitial()) {
    on<UpdateProfileInfo>((event, emit) async {
      emit(ProfileLoading());
      try {
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call.
        // Logic to update display name: user.updateDisplayName(event.nickname)
        emit(const ProfileSuccess("Profile updated successfully"));
      } catch (e) {
        emit(const ProfileFailure("Failed to update profile"));
      }
    });

    on<ChangePassword>((event, emit) async {
      emit(ProfileLoading());
      try {
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call.

        if (event.currentPassword == 'wrong') {
          emit(const ProfileFailure("Incorrect current password"));
        } else {
          // Logic to update password: user.updatePassword(event.newPassword)
          emit(const ProfileSuccess("Password changed successfully"));
        }
      } catch (e) {
        emit(const ProfileFailure("Failed to change password"));
      }
    });
  }
}
