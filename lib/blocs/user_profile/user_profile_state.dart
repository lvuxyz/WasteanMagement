import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileRefreshing extends UserProfileState {
  final UserProfile userProfile;

  const UserProfileRefreshing(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

class UserProfileLoaded extends UserProfileState {
  final UserProfile userProfile;

  const UserProfileLoaded(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserProfileUpdateSuccess extends UserProfileState {
  final String message;

  const UserProfileUpdateSuccess({this.message = 'Cập nhật thông tin thành công'});

  @override
  List<Object?> get props => [message];
} 