abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String username;

  AuthAuthenticated({required this.username});
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}