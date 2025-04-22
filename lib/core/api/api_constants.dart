class ApiConstants {
  // Base URL cho toàn bộ hệ thống
  static const String baseUrl = 'http://192.168.215.92:5000/api/v1/';

  // Các endpoint cụ thể
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String refreshToken = '$baseUrl/auth/refresh-token';
  static const String logout = '$baseUrl/auth/logout';
  static const String profile = '$baseUrl/users/profile';
  static const String changePassword = '$baseUrl/users/change-password';
  static const String updateProfile = '$baseUrl/users/update-profile';

  // Endpoint cho quản lý rác thải
  static const String wasteTypes = '$baseUrl/waste/types';
  static const String collectionPoints = '$baseUrl/waste/collection-points';
  static const String transactions = '$baseUrl/waste/transactions';
  static const String schedules = '$baseUrl/waste/schedules';
  static const String rewards = '$baseUrl/rewards';
}