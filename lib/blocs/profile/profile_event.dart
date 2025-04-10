abstract class ProfileEvent {}

class ProfileFetchEvent extends ProfileEvent {}

class ProfileUpdateEvent extends ProfileEvent {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;

  ProfileUpdateEvent({
    this.fullName,
    this.email,
    this.phone,
    this.address,
  });
} 