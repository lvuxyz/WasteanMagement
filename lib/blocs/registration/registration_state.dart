abstract class RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class RegistrationSuccess extends RegistrationState {
  final String username;

  RegistrationSuccess({required this.username});
}

class RegistrationFailure extends RegistrationState {
  final String error;

  RegistrationFailure({required this.error});
} 