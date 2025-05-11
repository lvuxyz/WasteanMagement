import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../generated/l10n.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final BuildContext context;

  ForgotPasswordBloc({required this.context}) : super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<ForgotPasswordReset>(_onForgotPasswordReset);
  }

  Future<void> _onForgotPasswordSubmitted(
      ForgotPasswordSubmitted event,
      Emitter<ForgotPasswordState> emit,
      ) async {
    emit(ForgotPasswordLoading());

    // Lấy chuỗi localization trước khi có bất kỳ async nào
    final l10n = S.of(context);
    final invalidEmailText = l10n.invalidEmail;
    final resetPasswordErrorText = l10n.resetPasswordError;

    try {
      // Validate email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(event.email)) {
        emit(ForgotPasswordFailure(error: invalidEmailText));
        return;
      }

      // Giả lập API call
      await Future.delayed(const Duration(seconds: 1));

      emit(ForgotPasswordSuccess(email: event.email));
    } catch (e) {
      emit(ForgotPasswordFailure(error: '$resetPasswordErrorText: $e'));
    }
  }


  void _onForgotPasswordReset(
    ForgotPasswordReset event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(ForgotPasswordInitial());
  }
} 

