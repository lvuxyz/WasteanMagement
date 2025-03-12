abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String email;

  ForgotPasswordSuccess({required this.email});
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;

  ForgotPasswordFailure({required this.error});
} 