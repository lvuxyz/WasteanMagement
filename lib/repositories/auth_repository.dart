import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/auth_credentials.dart';
import '../data/datasources/local_data_source.dart';

class AuthRepository {
  final LocalDataSource localDataSource;
  final String apiBaseUrl;
  
  AuthRepository({
    required this.localDataSource,
    required this.apiBaseUrl,
  });

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl${ApiConstants.login}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final userData = data['data'];
        final token = userData['token'];
        
        if (rememberMe) {
          // Store credentials locally
          await localDataSource.cacheAuthCredentials(
            AuthCredentials(
              token: token,
              userId: userData['user_id'] ?? userData['id'],
              email: email,
            ),
          );
        }
        
        return userData;
      } else {
        throw Exception(data['message'] ?? 'Đăng nhập thất bại');
      }
    } on SocketException {
      throw Exception('Lỗi kết nối mạng');
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }
}

