class AuthFormState {
  final String email;
  final String password;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isPasswordVisible;
  final bool rememberMe;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const AuthFormState({
    this.email = '',
    this.password = '',
    this.isEmailValid = false,
    this.isPasswordValid = false,
    this.isPasswordVisible = false,
    this.rememberMe = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  bool get isFormValid => isEmailValid && isPasswordValid;

  AuthFormState copyWith({
    String? email,
    String? password,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isPasswordVisible,
    bool? rememberMe,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

