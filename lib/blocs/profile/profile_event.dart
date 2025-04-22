import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {} // Đổi từ ProfileFetchEvent

class UpdateProfile extends ProfileEvent { // Đổi từ ProfileUpdateEvent
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;

  const UpdateProfile({
    this.fullName,
    this.email,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [fullName, email, phone, address];
}