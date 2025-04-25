import 'package:equatable/equatable.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object> get props => [];
}

class RegistrationSubmitted extends RegistrationEvent {
  final String fullName;
  final String username;
  final String email;
  final String password;
  final String phone;
  final String address;

  const RegistrationSubmitted({
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
  });

  @override
  List<Object> get props => [fullName, username, email, password, phone, address];
}

class RegistrationReset extends RegistrationEvent {} 

