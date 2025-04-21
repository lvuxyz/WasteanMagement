import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  // Sample user data for login
  final List<Map<String, String>> _sampleUsers = [
    {'username': 'admin', 'password': 'password', 'fullName': 'Admin User'},
    {'username': 'user1', 'password': '123456', 'fullName': 'Regular User'},
    {'username': 'test@example.com', 'password': 'test123', 'fullName': 'Test User'},
    {'username': 'admin@example.com', 'password': 'Admin123', 'fullName': 'Admin Example'},
  ];

  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      // Simulating API call
      await Future.delayed(const Duration(seconds: 1));

      // Check if the user exists in our sample data
      final user = _sampleUsers.firstWhere(
        (user) => (user['username'] == event.username && user['password'] == event.password),
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        emit(LoginSuccess(username: user['fullName'] ?? event.username));
      } else {
        emit(LoginFailure(error: 'Thông tin đăng nhập không chính xác'));
      }
    } catch (e) {
      emit(LoginFailure(error: 'Đã xảy ra lỗi: $e'));
    }
  }

  void _onLoginReset(
    LoginReset event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginInitial());
  }
}

