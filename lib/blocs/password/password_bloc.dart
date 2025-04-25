import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/repositories/user_repository.dart';
import '../../core/error/exceptions.dart';
import 'password_event.dart';
import 'password_state.dart';

class PasswordBloc extends Bloc<PasswordEvent, PasswordState> {
  final UserRepository userRepository;

  PasswordBloc({required this.userRepository}) : super(PasswordInitial()) {
    on<ChangePassword>(_onChangePassword);
  }

  Future<void> _onChangePassword(
      ChangePassword event,
      Emitter<PasswordState> emit,
      ) async {
    // Validate that new password and confirm password match
    if (event.newPassword != event.confirmPassword) {
      emit(const PasswordError('Mật khẩu xác nhận không khớp'));
      return;
    }

    emit(PasswordLoading());
    try {
      await userRepository.changePassword(
        event.currentPassword,
        event.newPassword,
      );
      emit(PasswordChanged());
    } on UnauthorizedException catch (e) {
      emit(PasswordError(e.toString()));
    } catch (e) {
      emit(PasswordError(e.toString()));
    }
  }
}