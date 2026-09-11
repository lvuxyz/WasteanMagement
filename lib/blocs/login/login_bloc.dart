import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/repositories/user_repository.dart';
import '../../core/error/exceptions.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart' as auth_events;
import 'login_event.dart';
import 'login_state.dart';
import '../../utils/app_logger.dart';

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

    try {
      // Đăng nhập và lấy thông tin user
      final user = await userRepository.login(
        event.username,
        event.password,
      );

      // Cập nhật trạng thái thành công
      emit(LoginSuccess(username: user.fullName));

      // Cập nhật AuthBloc
      if (authBloc != null) {
        // Sử dụng CheckAuthenticationStatus từ AuthBloc
        authBloc!.add(auth_events.CheckAuthenticationStatus());
      }
    } on UnauthorizedException catch (e) {
      AppLogger.w('Auth', 'Đăng nhập thất bại · ${e.message}');
      emit(LoginFailure(error: 'Thông tin đăng nhập không chính xác'));
    } catch (e) {
      // Kiểm tra nếu thông báo lỗi chứa "Đăng nhập thành công" thì đó không phải lỗi thực sự
      if (e.toString().contains('Đăng nhập thành công')) {
        // Đây thực sự là một thành công, nhưng bị xử lý như lỗi
        AppLogger.w('Auth', 'Server trả lỗi nhưng thực chất đăng nhập thành công · $e');
        emit(LoginSuccess(username: event.username));

        // Cập nhật AuthBloc
        if (authBloc != null) {
          authBloc!.add(auth_events.CheckAuthenticationStatus());
        }
      } else {
        AppLogger.w('Auth', 'Đăng nhập thất bại · $e');
        emit(LoginFailure(error: 'Đã xảy ra lỗi: $e'));
      }
    }
  }

  void _onLoginReset(
      LoginReset event,
      Emitter<LoginState> emit,
      ) {
    AppLogger.d('Auth', 'Reset trạng thái đăng nhập');
    emit(LoginInitial());
  }
}