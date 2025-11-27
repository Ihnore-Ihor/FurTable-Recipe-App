import 'package:equatable/equatable.dart';

/// Abstract base class for the state of the profile screen.
abstract class ProfileState extends Equatable {
  /// Creates a [ProfileState].
  const ProfileState();
  @override
  List<Object> get props => [];
}

/// Initial state of the profile screen.
class ProfileInitial extends ProfileState {}

/// State indicating that a profile operation is in progress.
class ProfileLoading extends ProfileState {}

/// State indicating that a profile operation completed successfully.
class ProfileSuccess extends ProfileState {
  /// The success message.
  final String message;

  /// Creates a [ProfileSuccess] state.
  const ProfileSuccess(this.message);
}

/// State indicating that an error occurred during a profile operation.
class ProfileFailure extends ProfileState {
  /// The error message.
  final String error;

  /// Creates a [ProfileFailure] state.
  const ProfileFailure(this.error);
}
