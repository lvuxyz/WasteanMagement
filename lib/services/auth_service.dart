import 'dart:convert';
import 'dart:math' as Math;
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/storage_keys.dart';

class AuthService {
  static const String _tokenKey = SecureStorageKeys.token;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      developer.log('AuthService.getToken() from secure storage: ${token != null ? "Token found" : "No token found"}');
      return token;
    } catch (e) {
      developer.log('Error in getToken: $e', error: e);
      return null;
    }
  }
  
  Future<bool> isAdmin() async {
    try {
      final token = await getToken();
      print('Checking admin status with token: ${token != null ? token.substring(0, Math.min(20, token.length)) : "null"}...');
      
      if (token == null) {
        print('Token is null, user is not admin');
        return false;
      }
      
      // Decode JWT token
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Invalid token format, parts length: ${parts.length}');
        return false;
      }
      
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
      
      print('Token does not contain roles or roles is not a list');
      return false;
    } catch (e) {
      print('Error decoding JWT: $e');
      return false;
    }
  }
} 