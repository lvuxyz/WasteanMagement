import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api/api_constants.dart';
import 'registration_event.dart';
import 'registration_state.dart';
import '../../utils/app_logger.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final BuildContext context;

  RegistrationBloc({required this.context}) : super(RegistrationInitial()) {
    on<RegistrationSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    try {
      emit(RegistrationLoading());

      AppLogger.d('Register', 'Đăng ký tài khoản · username=${event.username}');

      // API call
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'full_name': event.fullName,
          'username': event.username,
          'email': event.email,
          'password': event.password,
          'phone': event.phone,
          'address': event.address,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful
        emit(RegistrationSuccess());
      } else {
        // Error handling
        final errorMessage = responseData['message'] ?? 'Registration failed';
        emit(RegistrationFailure(error: errorMessage));
      }
    } catch (e) {
      AppLogger.w('Register', 'Đăng ký thất bại · $e');
      emit(RegistrationFailure(error: e.toString()));
    }
  }
}

