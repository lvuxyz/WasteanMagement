class AuthRepository {
  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email != 'admin@example.com' || password != 'Admin123') {
      throw Exception('Email hoặc mật khẩu không chính xác');
    }

    if (rememberMe) {
      // TODO: Implement token storage
    }
  }
}
