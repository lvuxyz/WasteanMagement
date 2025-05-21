import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;

  const ProfileLoaded({required this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;

  const ProfileUpdateSuccess({this.message = 'Cập nhật thông tin thành công'});

  @override
  List<Object?> get props => [message];
}