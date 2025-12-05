import 'package:equatable/equatable.dart';

/// Abstract base class for profile-related events.
abstract class ProfileEvent extends Equatable {
  /// Creates a [ProfileEvent].
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

/// Event triggered to update the user's profile information.
class UpdateProfileInfo extends ProfileEvent {
  /// The new nickname for the user.
  final String nickname;

  /// The new avatar path for the user.
  final String avatarPath;

  /// Creates an [UpdateProfileInfo] event.
  const UpdateProfileInfo({
    required this.nickname,
    required this.avatarPath,
  });

  @override
  List<Object> get props => [nickname, avatarPath];
}

/// Event triggered to change the user's password.
class ChangePassword extends ProfileEvent {
  /// The current password for verification.
  final String currentPassword;

  /// The new password to set.
  final String newPassword;

  /// Creates a [ChangePassword] event.
  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
  });
}
