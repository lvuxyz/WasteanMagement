import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String fullName;
  final String email;
  final String? phone;
  final String? address;

  const UpdateProfile({
    required this.fullName,
    required this.email,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [fullName, email, phone, address];
}