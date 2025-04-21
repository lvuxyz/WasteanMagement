import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Sample user data for login
  final List<Map<String, String>> _sampleUsers = [
    {'username': 'admin', 'password': 'password', 'fullName': 'Admin User'},
    {'username': 'user1', 'password': '123456', 'fullName': 'Regular User'},
    {'username': 'test@example.com', 'password': 'test123', 'fullName': 'Test User'},
    {'username': 'admin@example.com', 'password': 'Admin123', 'fullName': 'Admin Example'},
  ];

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<RegisterEvent>(_onRegisterEvent);
    on<LogoutEvent>(_onLogoutEvent);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Simulating API call
      await Future.delayed(const Duration(seconds: 1));

      // Check if the user exists in our sample data
      final user = _sampleUsers.firstWhere(
        (user) => (user['username'] == event.username && user['password'] == event.password),
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        emit(AuthAuthenticated(username: user['fullName'] ?? event.username));
      } else {
        emit(AuthError(message: 'Thông tin đăng nhập không chính xác'));
      }
    } catch (e) {
      emit(AuthError(message: 'Đã xảy ra lỗi: $e'));
    }
  }

  Future<void> _onRegisterEvent(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // Validate passwords match
      if (event.password != event.confirmPassword) {
        emit(AuthError(message: 'Mật khẩu xác nhận không khớp'));
        return;
      }
      
      // Check if email already exists
      final existingUser = _sampleUsers.any((user) => user['username'] == event.email);
      if (existingUser) {
        emit(AuthError(message: 'Email đã được sử dụng'));
        return;
      }
      
      // Simulating API call for registration
      await Future.delayed(const Duration(seconds: 1));
      
      // Add new user to sample data (in a real app, this would be an API call)
      _sampleUsers.add({
        'username': event.email,
        'password': event.password,
        'fullName': event.email.split('@')[0],
      });
      
      emit(AuthAuthenticated(username: event.email.split('@')[0]));
    } catch (e) {
      emit(AuthError(message: 'Đăng ký thất bại: $e'));
    }
  }

  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthInitial());
  }
}

