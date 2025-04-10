import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'registration_event.dart';
import 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final BuildContext context;

  RegistrationBloc({required this.context}) : super(RegistrationInitial()) {
    on<RegistrationSubmitted>(_onRegistrationSubmitted);
    on<RegistrationReset>(_onRegistrationReset);
  }

  Future<void> _onRegistrationSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationLoading());

    try {
      final l10n = AppLocalizations.of(context);
      final passwordsDoNotMatchText = l10n.passwordsDoNotMatch;

      // Validate passwords match
      if (event.password != event.confirmPassword) {
        emit(RegistrationFailure(error: passwordsDoNotMatchText));
        return;
      }

      // Simulate API call for registration
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would be an API call to register the user
      // For now, we'll just simulate a successful registration
      final username = event.email.split('@')[0];
      emit(RegistrationSuccess(username: username));
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      final registrationErrorText = l10n.registrationError;
      emit(RegistrationFailure(error: '$registrationErrorText: $e'));
    }
  }

  void _onRegistrationReset(
    RegistrationReset event,
    Emitter<RegistrationState> emit,
  ) {
    emit(RegistrationInitial());
  }
} 