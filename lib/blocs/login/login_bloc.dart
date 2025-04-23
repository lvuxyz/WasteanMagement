import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../core/error/exceptions.dart';
import '../../data/repositories/user_repository.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart' as auth_events;
import 'login_event.dart';
import 'login_state.dart';
import '../../models/user_model.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthBloc? authBloc;

  LoginBloc({
    required this.userRepository,
    this.authBloc,
  }) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginLoading());
    developer.log('Đang thực hiện đăng nhập với username: ${event.username}');

    try {
      // Sử dụng repository để đăng nhập
      final user = await userRepository.login(
        event.username,
        event.password,
      );

      developer.log('Đăng nhập thành công, username: ${user.username}, fullName: ${user.fullName}');

      // Emit trạng thái thành công
      emit(LoginSuccess(username: user.fullName));

      // Cập nhật AuthBloc nếu có thể truy cập
      if (authBloc != null) {
        developer.log('Cập nhật AuthBloc với sự kiện CheckAuthenticationStatus');
        // Sử dụng sự kiện phù hợp từ AuthBloc thay vì LoginSubmitted
        authBloc!.add(auth_events.CheckAuthenticationStatus());
      } else {
        developer.log('AuthBloc không được cung cấp, không thể cập nhật trạng thái xác thực');
      }
    } on UnauthorizedException catch (e) {
      developer.log('Đăng nhập thất bại (Unauthorized): ${e.toString()}');
      emit(LoginFailure(error: 'Thông tin đăng nhập không chính xác'));
    } catch (e) {
      developer.log('Đăng nhập thất bại với lỗi: ${e.toString()}');

      // Kiểm tra thông báo lỗi để tránh mâu thuẫn
      String errorMessage = e.toString();
      if (errorMessage.contains('Đăng nhập thành công')) {
        emit(LoginSuccess(username: event.username));
      } else {
        emit(LoginFailure(error: 'Đã xảy ra lỗi: $e'));
      }
    }
  }

  void _onLoginReset(
      LoginReset event,
      Emitter<LoginState> emit,
      ) {
    developer.log('Reset trạng thái đăng nhập');
    emit(LoginInitial());
  }
}