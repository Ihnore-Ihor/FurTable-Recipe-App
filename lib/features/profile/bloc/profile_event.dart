import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class UpdateProfileInfo extends ProfileEvent {
  final String nickname;
  const UpdateProfileInfo(this.nickname);
}

class ChangePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
  });
}
