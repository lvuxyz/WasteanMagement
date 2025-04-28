class ApiConstants {
  // Base URL cho toàn bộ hệ thống
  // Đổi thành true để sử dụng localhost cho emulator
  static const bool useEmulator = false;
  
  // URL cho các môi trường khác nhau
  static const String _emulatorBaseUrl = 'http://10.0.2.2:5000/api/v1'; // Localhost trên emulator
  static const String _physicalDeviceBaseUrl = 'http://192.168.215.92:5000/api/v1'; // IP máy chủ trên mạng LAN
  
  // Chọn URL dựa trên môi trường
  static String get baseUrl => useEmulator ? _emulatorBaseUrl : _physicalDeviceBaseUrl;

  // Các endpoint cụ thể
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get refreshToken => '$baseUrl/auth/refresh-token';
  static String get logout => '$baseUrl/auth/logout';
  static String get profile => '$baseUrl/auth/me';
  static String get changePassword => '$baseUrl/users/change-password';
  static String get updateProfile => '$baseUrl/users/update-profile';

  // Endpoint cho quản lý rác thải
  static String get wasteTypes => '$baseUrl/waste-types';
  static String get collectionPoints => '$baseUrl/waste/collection-points';
  static String get transactions => '$baseUrl/waste/transactions';
  static String get schedules => '$baseUrl/waste/schedules';
  static String get rewards => '$baseUrl/rewards';
}