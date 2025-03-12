abstract class RegistrationEvent {}

class RegistrationSubmitted extends RegistrationEvent {
  final String email;
  final String password;
  final String confirmPassword;

  RegistrationSubmitted({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}

class RegistrationReset extends RegistrationEvent {} 