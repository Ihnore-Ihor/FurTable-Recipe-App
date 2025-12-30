import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furtable/features/explore/repositories/recipe_repository.dart';
import 'package:furtable/features/profile/bloc/profile_event.dart';
import 'package:furtable/features/profile/bloc/profile_state.dart';
import 'package:furtable/features/profile/repositories/user_repository.dart';

/// Manages the state of the user profile, including updates and password changes.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  final UserRepository _userRepo = UserRepository();

  /// Creates a [ProfileBloc] and registers event handlers.
  ProfileBloc() : super(ProfileInitial()) {
    
    // Updates nickname and avatar.
    on<UpdateProfileInfo>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // 1. Update Auth profile
          await user.updateDisplayName(event.nickname);
          // Update photo URL (using local path for this implementation)
          await user.updatePhotoURL(event.avatarPath);
          
          try {
             await user.reload().timeout(const Duration(seconds: 5));
          } catch (_) {
             // Ignore reload error, as long as update succeeded.
          }
          // 2. Update Collection Users (Source of Truth)
          await _userRepo.saveUserProfile(user.uid, event.nickname, event.avatarPath);

          // 3. Update all recipes authored by this user in the database.
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

    // Changes the user's password.
    on<ChangePassword>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email != null) {
          // 1. Re-authenticate first (security requirement).
          final cred = EmailAuthProvider.credential(
            email: user.email!, 
            password: event.currentPassword
          );
          await user.reauthenticateWithCredential(cred);

          // 2. Now change the password.
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

    // Permanently deletes the user's account and data.
    on<DeleteAccount>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // 1. Delete data from database while we still have permissions.
          await _userRepo.deleteUserData(user.uid);

          // 2. Delete the user from Auth.
          await user.delete();

          emit(const ProfileSuccess("Account deleted successfully"));
        } else {
          emit(const ProfileFailure("User not logged in"));
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          emit(const ProfileFailure("Please log out and log in again to delete your account."));
        } else {
          emit(ProfileFailure(e.message ?? "Failed to delete account"));
        }
      } catch (e) {
        emit(const ProfileFailure("An error occurred during account deletion"));
      }
    });
  }
}
