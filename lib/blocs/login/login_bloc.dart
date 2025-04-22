import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/error/exceptions.dart';
import '../../data/repositories/user_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;

  LoginBloc({required this.userRepository}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginLoading());

    try {
      // Sử dụng repository để đăng nhập
      final user = await userRepository.login(
        event.username,
        event.password,
      );

      // Sử dụng fullName thay vì username để hiển thị
      emit(LoginSuccess(username: user.fullName));
    } on UnauthorizedException {
      emit(LoginFailure(error: 'Thông tin đăng nhập không chính xác'));
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