import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import '../../core/error/exceptions.dart';
import '../../utils/constants.dart';

class RemoteDataSource {
  final http.Client client;
  final String baseUrl = ApiConstants.baseUrl;

  RemoteDataSource({required this.client});

  // Flag để sử dụng dữ liệu mẫu trong giai đoạn phát triển
  final bool useMockData = true;

  // Authentication endpoints
  Future<Map<String, dynamic>> login(String username, String password) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));

      if ((username == 'admin' && password == 'password') ||
          (username == 'user1' && password == '123456')) {

        return {
          'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': '1',
            'email': username.contains('@') ? username : '$username@example.com',
            'username': username,
            'full_name': username == 'admin' ? 'Admin User' : 'Regular User',
            'status': 'active',
            'created_at': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
          }
        };
      } else {
        throw UnauthorizedException('Tên đăng nhập hoặc mật khẩu không đúng');
      }
    }

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Thông tin đăng nhập không chính xác');
      } else {
        throw ServerException('Đã xảy ra lỗi: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> logout(String token) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw ServerException('Đăng xuất thất bại: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // User profile endpoints
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));

      return {
        'id': '1',
        'email': 'user@example.com',
        'username': 'user123',
        'full_name': 'Nguyễn Văn A',
        'phone': '+84 123 456 789',
        'address': '123 Đường Lê Lợi, Quận 1, TP.HCM',
        'status': 'active',
        'created_at': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
      };
    }

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Token hết hạn hoặc không hợp lệ');
      } else {
        throw ServerException('Lấy thông tin người dùng thất bại: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    String? fullName,
    String? email,
    String? phone,
    String? address,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));

      return {
        'id': '1',
        'email': email ?? 'user@example.com',
        'username': 'user123',
        'full_name': fullName ?? 'Nguyễn Văn A',
        'phone': phone ?? '+84 123 456 789',
        'address': address ?? '123 Đường Lê Lợi, Quận 1, TP.HCM',
        'status': 'active',
        'created_at': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
    }

    final Map<String, dynamic> requestBody = {};

    if (fullName != null) requestBody['full_name'] = fullName;
    if (email != null) requestBody['email'] = email;
    if (phone != null) requestBody['phone'] = phone;
    if (address != null) requestBody['address'] = address;

    try {
      final response = await client.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Token hết hạn hoặc không hợp lệ');
      } else {
        throw ServerException('Cập nhật thông tin người dùng thất bại: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));

      if (currentPassword != 'password') {
        throw UnauthorizedException('Mật khẩu hiện tại không đúng');
      }

      return;
    }

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/users/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        final responseBody = jsonDecode(response.body);
        throw UnauthorizedException(responseBody['message'] ?? 'Mật khẩu hiện tại không đúng');
      } else {
        throw ServerException('Thay đổi mật khẩu thất bại: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw ServerException('Yêu cầu đặt lại mật khẩu thất bại: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}