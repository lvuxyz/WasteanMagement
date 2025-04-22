import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/error/exceptions.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({required this.userRepository}) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthenticationStatus>(_onCheckAuthenticationStatus);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final user = await userRepository.login(
        event.username,
        event.password,
      );
      emit(Authenticated(user));
    } on UnauthorizedException catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    // Implement registration logic
    emit(AuthLoading());
    // Add logic here based on your user repository methods
  }

  Future<void> _onForgotPasswordSubmitted(
      ForgotPasswordSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      await userRepository.forgotPassword(event.email);
      emit(ForgotPasswordSent(event.email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Trong AuthBloc class, phương thức _onLogoutRequested
  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      await userRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthenticationStatus(
      CheckAuthenticationStatus event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await userRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await userRepository.getUserProfile();
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } on UnauthorizedException {
      emit(Unauthenticated());
    } catch (e) {
      emit(Unauthenticated());
    }
  }

}