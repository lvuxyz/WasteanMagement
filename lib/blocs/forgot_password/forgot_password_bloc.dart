import 'package:flutter_bloc/flutter_bloc.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<ForgotPasswordReset>(_onForgotPasswordReset);
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());

    try {
      // Validate email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(event.email)) {
        emit(ForgotPasswordFailure(error: 'Email không hợp lệ'));
        return;
      }

      // Simulate API call for password reset
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would be an API call to send a password reset email
      // For now, we'll just simulate a successful password reset request
      emit(ForgotPasswordSuccess(email: event.email));
    } catch (e) {
      emit(ForgotPasswordFailure(error: 'Gửi yêu cầu thất bại: $e'));
    }
  }

  void _onForgotPasswordReset(
    ForgotPasswordReset event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(ForgotPasswordInitial());
  }
} 