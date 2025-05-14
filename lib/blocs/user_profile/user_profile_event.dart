import 'package:equatable/equatable.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserProfile extends UserProfileEvent {
  const FetchUserProfile();
}

class RefreshUserProfile extends UserProfileEvent {
  const RefreshUserProfile();
}

class UpdateUserProfile extends UserProfileEvent {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;

  const UpdateUserProfile({
    this.fullName,
    this.email,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [fullName, email, phone, address];
} 