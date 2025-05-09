import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  Future<bool> isAdmin() async {
    final token = await getToken();
    if (token == null) return false;
    
    try {
      // Decode JWT token
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      final payload = parts[1];
      String normalizedPayload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      final payloadMap = json.decode(decoded);
      
      // Log the payload for debugging
      print('JWT payload: $payloadMap');
      
      // Check if the roles array contains 'ADMIN'
      if (payloadMap.containsKey('roles') && payloadMap['roles'] is List) {
        final roles = List<String>.from(payloadMap['roles']);
        final isAdmin = roles.contains('ADMIN');
        print('User has roles: $roles, isAdmin: $isAdmin');
        return isAdmin;
      }
      
      return false;
    } catch (e) {
      print('Error decoding JWT: $e');
      return false;
    }
  }
} 