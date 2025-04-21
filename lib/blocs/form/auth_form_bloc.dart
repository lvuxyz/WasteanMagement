import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:email_validator/email_validator.dart';
import 'auth_form_event.dart';
import 'auth_form_state.dart';
import '../../repositories/auth_repository.dart';

class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  final AuthRepository authRepository;

  AuthFormBloc({required this.authRepository}) : super(const AuthFormState()) {
    on<EmailChanged>(
      _onEmailChanged,
      transformer: (events, mapper) =>
          events.debounceTime(const Duration(milliseconds: 300)).asyncExpand(mapper),
    );
    on<PasswordChanged>(_onPasswordChanged);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<RememberMeChanged>(_onRememberMeChanged);
    on<FormSubmitted>(_onFormSubmitted);
  }

  void _onEmailChanged(EmailChanged event, Emitter<AuthFormState> emit) {
    final isValid = EmailValidator.validate(event.email);
    emit(state.copyWith(email: event.email, isEmailValid: isValid, errorMessage: null));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<AuthFormState> emit) {
    final password = event.password;
    final isValid = password.length >= 6 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'));

    emit(state.copyWith(password: password, isPasswordValid: isValid, errorMessage: null));
  }

  void _onTogglePasswordVisibility(TogglePasswordVisibility event, Emitter<AuthFormState> emit) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onRememberMeChanged(RememberMeChanged event, Emitter<AuthFormState> emit) {
    emit(state.copyWith(rememberMe: event.rememberMe));
  }

  Future<void> _onFormSubmitted(FormSubmitted event, Emitter<AuthFormState> emit) async {
    if (!state.isFormValid) {
      emit(state.copyWith(errorMessage: 'Vui lòng kiểm tra lại thông tin đăng nhập'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await authRepository.login(
        email: state.email,
        password: state.password,
        rememberMe: state.rememberMe,
      );
      emit(state.copyWith(isSuccess: true, isSubmitting: false));
    } catch (error) {
      String errorMessage = 'Đăng nhập thất bại';
      if (error.toString().contains('mật khẩu không chính xác')) {
        errorMessage = 'Email hoặc mật khẩu không đúng!';
      } else if (error.toString().contains('network')) {
        errorMessage = 'Không có kết nối mạng, vui lòng thử lại!';
      }
      emit(state.copyWith(isSubmitting: false, errorMessage: errorMessage));
    }
  }
}

