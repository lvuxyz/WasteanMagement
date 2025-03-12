import 'package:flutter_bloc/flutter_bloc.dart';
import 'registration_event.dart';
import 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc() : super(RegistrationInitial()) {
    on<RegistrationSubmitted>(_onRegistrationSubmitted);
    on<RegistrationReset>(_onRegistrationReset);
  }

  Future<void> _onRegistrationSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationLoading());

    try {
      // Validate passwords match
      if (event.password != event.confirmPassword) {
        emit(RegistrationFailure(error: 'Mật khẩu xác nhận không khớp'));
        return;
      }

      // Simulate API call for registration
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would be an API call to register the user
      // For now, we'll just simulate a successful registration
      final username = event.email.split('@')[0];
      emit(RegistrationSuccess(username: username));
    } catch (e) {
      emit(RegistrationFailure(error: 'Đăng ký thất bại: $e'));
    }
  }

  void _onRegistrationReset(
    RegistrationReset event,
    Emitter<RegistrationState> emit,
  ) {
    emit(RegistrationInitial());
  }
} 