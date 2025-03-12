class LoginCredentials {
  final String username;
  final String password;
  
  LoginCredentials({
    required this.username,
    required this.password,
  });
}

class RegistrationCredentials {
  final String email;
  final String password;
  final String confirmPassword;
  
  RegistrationCredentials({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}

class ForgotPasswordCredentials {
  final String email;
  
  ForgotPasswordCredentials({
    required this.email,
  });
} 