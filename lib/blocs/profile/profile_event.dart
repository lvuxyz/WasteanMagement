import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final bool forceRefresh;
  
  const LoadProfile({this.forceRefresh = false});
  
  @override
  List<Object?> get props => [forceRefresh];
}

class UpdateProfile extends ProfileEvent {
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