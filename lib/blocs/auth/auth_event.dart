import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String username;
  final String password;

  const LoginSubmitted({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class RegisterSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [email, password, confirmPassword];
}

class ForgotPasswordSubmitted extends AuthEvent {
  final String email;

  const ForgotPasswordSubmitted({required this.email});

  @override
  List<Object> get props => [email];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthenticationStatus extends AuthEvent {}
