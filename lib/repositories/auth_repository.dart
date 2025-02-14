import 'dart:io';

class AuthRepository {
  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      if (email != 'admin@example.com' || password != 'Admin123') {
        throw Exception('Email hoặc mật khẩu không chính xác');
      }

      if (rememberMe) {
        // TODO: Implement token storage
      }
    } on SocketException {
      throw Exception('Lỗi kết nối mạng');
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }
}
