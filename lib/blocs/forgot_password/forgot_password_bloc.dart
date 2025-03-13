import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

    try {
      final l10n = AppLocalizations.of(context);
      final invalidEmailText = l10n != null ? l10n.invalidEmail : 'Please enter a valid email address';
      final resetPasswordErrorText = l10n != null ? l10n.resetPasswordError : 'Failed to send reset password link';

      // Validate email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(event.email)) {
        emit(ForgotPasswordFailure(error: invalidEmailText));
        return;
      }

      // Simulate API call for password reset
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would be an API call to send a password reset email
      // For now, we'll just simulate a successful password reset request
      emit(ForgotPasswordSuccess(email: event.email));
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      final resetPasswordErrorText = l10n != null ? l10n.resetPasswordError : 'Failed to send reset password link';
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