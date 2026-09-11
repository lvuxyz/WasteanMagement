/// Khóa cho flutter_secure_storage. Đây là nơi duy nhất khai báo các khóa
/// này — mọi lớp đọc/ghi secure storage phải dùng chung, nếu không dữ liệu
/// sẽ nằm rải ở nhiều khóa khác nhau mà không có lỗi nào báo ra.
class SecureStorageKeys {
  static const String token = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String user = 'user_data';
}

class PreferenceKeys {
  static const String userProfile = 'user_profile';
  static const String languageCode = 'language_code';
  static const String isDarkMode = 'is_dark_mode';
}