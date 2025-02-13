abstract class AuthEvent {}

class LoginButtonPressed extends AuthEvent {
  final String username;
  final String password;

  LoginButtonPressed({required this.username, required this.password});
}

class RegisterButtonPressed extends AuthEvent {} 