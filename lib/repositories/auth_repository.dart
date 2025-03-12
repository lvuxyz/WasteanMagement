import 'dart:io';

class AuthRepository {
  // Sample user data for login
  final List<Map<String, String>> _sampleUsers = [
    {'email': 'admin', 'password': 'password', 'fullName': 'Admin User'},
    {'email': 'user1', 'password': '123456', 'fullName': 'Regular User'},
    {'email': 'test@example.com', 'password': 'test123', 'fullName': 'Test User'},
    {'email': 'admin@example.com', 'password': 'Admin123', 'fullName': 'Admin Example'},
  ];

  Future<Map<String, String>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Find user in sample data
      final user = _sampleUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (user.isEmpty) {
        throw Exception('Email hoặc mật khẩu không chính xác');
      }

      if (rememberMe) {
        // TODO: Implement token storage
      }
      
      return user;
    } on SocketException {
      throw Exception('Lỗi kết nối mạng');
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }
}
