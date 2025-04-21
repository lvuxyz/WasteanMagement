class ApiConstants {
  static const String baseUrl = 'https://api.wastemanagement.com'; // Replace with your actual API URL
  
  // API endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String profile = '/api/users/profile';
  
  // Shared preferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}

class AppConstants {
  static const String appName = 'Waste Management';
  static const String appVersion = '1.0.0';
} 

