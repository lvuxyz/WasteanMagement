abstract class AuthFormEvent {
  const AuthFormEvent();
}

class EmailChanged extends AuthFormEvent {
  final String email;
  const EmailChanged(this.email);
}

class PasswordChanged extends AuthFormEvent {
  final String password;
  const PasswordChanged(this.password);
}

class TogglePasswordVisibility extends AuthFormEvent {
  const TogglePasswordVisibility();
}

class RememberMeChanged extends AuthFormEvent {
  final bool rememberMe;
  const RememberMeChanged(this.rememberMe);
}

class FormSubmitted extends AuthFormEvent {
  const FormSubmitted();
}

