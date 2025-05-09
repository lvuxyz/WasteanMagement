import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  static const String baseUrl = 'http://your-api-url';
  static const storage = FlutterSecureStorage();
  
  static const String tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    return await storage.read(key: tokenKey);
  }
} 