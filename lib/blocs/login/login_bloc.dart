import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/repositories/user_repository.dart';
import 'dart:developer' as developer;
import '../../core/error/exceptions.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart' as auth_events;
import 'login_event.dart';
import 'login_state.dart';

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
      // Đăng nhập và lấy thông tin user
      final user = await userRepository.login(
        event.username,
        event.password,
      );

      developer.log('Đăng nhập thành công, username: ${user.username}, fullName: ${user.fullName}');

      // Cập nhật trạng thái thành công
      emit(LoginSuccess(username: user.fullName));

      // Cập nhật AuthBloc
      if (authBloc != null) {
        developer.log('Cập nhật AuthBloc với sự kiện CheckAuthenticationStatus');
        // Sử dụng CheckAuthenticationStatus từ AuthBloc
        authBloc!.add(auth_events.CheckAuthenticationStatus());
      }
    } on UnauthorizedException catch (e) {
      developer.log('Đăng nhập thất bại (Unauthorized): ${e.toString()}');
      emit(LoginFailure(error: 'Thông tin đăng nhập không chính xác'));
    } catch (e) {
      // Kiểm tra nếu thông báo lỗi chứa "Đăng nhập thành công" thì đó không phải lỗi thực sự
      if (e.toString().contains('Đăng nhập thành công')) {
        // Đây thực sự là một thành công, nhưng bị xử lý như lỗi
        developer.log('Phát hiện lỗi sai: ${e.toString()} - Đây là thành công');
        emit(LoginSuccess(username: event.username));
        
        // Cập nhật AuthBloc
        if (authBloc != null) {
          developer.log('Cập nhật AuthBloc với sự kiện CheckAuthenticationStatus');
          authBloc!.add(auth_events.CheckAuthenticationStatus());
        }
      } else {
        developer.log('Đăng nhập thất bại với lỗi: ${e.toString()}');
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