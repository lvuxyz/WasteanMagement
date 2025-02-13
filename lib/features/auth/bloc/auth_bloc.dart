import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(AuthLoading());
      // TODO: Implement login logic
    });

    on<RegisterButtonPressed>((event, emit) async {
      // TODO: Implement register logic
    });
  }
} 