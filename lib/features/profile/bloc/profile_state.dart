import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final String message;
  const ProfileSuccess(this.message);
}

class ProfileFailure extends ProfileState {
  final String error;
  const ProfileFailure(this.error);
}
