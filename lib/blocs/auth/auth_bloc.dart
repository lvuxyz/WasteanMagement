import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<RegisterEvent>(_onRegisterEvent);
    on<LogoutEvent>(_onLogoutEvent);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Simulating API call
      await Future.delayed(const Duration(seconds: 2));

      if (event.username == 'admin' && event.password == 'password') {
        emit(AuthAuthenticated(username: event.username));
      } else {
        emit(AuthError(message: 'Thông tin đăng nhập không chính xác'));
      }
    } catch (e) {
      emit(AuthError(message: 'Đã xảy ra lỗi: $e'));
    }
  }

  Future<void> _onRegisterEvent(RegisterEvent event, Emitter<AuthState> emit) async {
    // TODO: Implement register logic
  }

  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthInitial());
  }
}