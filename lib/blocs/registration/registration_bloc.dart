import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import '../../core/api/api_constants.dart';
import 'registration_event.dart';
import 'registration_state.dart';

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
      
      developer.log('Attempting to register user: ${event.username}');
      
      // API call
      final response = await http.post(
        Uri.parse('${ApiConstants.register}'),
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
      
      developer.log('Registration response status: ${response.statusCode}');
      developer.log('Registration response body: ${response.body}');

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
      developer.log('Registration error: $e');
      emit(RegistrationFailure(error: e.toString()));
    }
  }
} 

