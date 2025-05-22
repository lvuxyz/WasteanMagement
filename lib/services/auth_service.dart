import 'dart:convert';
import 'dart:math' as Math;
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/storage_keys.dart';

class AuthService {
  static const String _tokenKey = SecureStorageKeys.token;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Cache cho admin status
  bool? _cachedAdminStatus;
  DateTime? _cachedAdminStatusTime;
  
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
    // Kiểm tra cache, nếu cache còn hiệu lực (dưới 10 giây) thì dùng giá trị cache
    final now = DateTime.now();
    if (_cachedAdminStatus != null && _cachedAdminStatusTime != null) {
      final cacheDuration = now.difference(_cachedAdminStatusTime!);
      if (cacheDuration.inSeconds < 10) {
        print('===== ADMIN CHECK =====');
        print('Using cached admin status: $_cachedAdminStatus (cache age: ${cacheDuration.inSeconds}s)');
        print('=====================');
        return _cachedAdminStatus!;
      }
    }
    
    try {
      final token = await getToken();
      print('===== ADMIN CHECK =====');
      print('Checking admin status with token: ${token != null ? token.substring(0, Math.min(20, token.length)) : "null"}...');
      
      if (token == null) {
        print('ADMIN CHECK RESULT: Token is null, user is NOT ADMIN');
        _updateAdminCache(false);
        return false;
      }
      
      // Decode JWT token
      final parts = token.split('.');
      if (parts.length != 3) {
        print('ADMIN CHECK RESULT: Invalid token format, parts length: ${parts.length}, user is NOT ADMIN');
        _updateAdminCache(false);
        return false;
      }
      
      try {
        final payload = parts[1];
        String normalizedPayload = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalizedPayload));
        final payloadMap = json.decode(decoded);
        
        // Log the payload for debugging
        print('JWT payload: $payloadMap');
        
        // Check if the roles array contains 'ADMIN'
        if (payloadMap.containsKey('roles') && payloadMap['roles'] is List) {
          final roles = List<String>.from(payloadMap['roles']);
          final isAdmin = roles.contains('ADMIN') || roles.contains('admin');
          print('ADMIN CHECK RESULT: User has roles: $roles, isAdmin: $isAdmin');
          _updateAdminCache(isAdmin);
          return isAdmin;
        }
        
        print('ADMIN CHECK RESULT: Token does not contain roles or roles is not a list, user is NOT ADMIN');
        _updateAdminCache(false);
        return false;
      } catch (e) {
        print('ADMIN CHECK RESULT: Error parsing token payload: $e, user is NOT ADMIN');
        _updateAdminCache(false);
        return false;
      }
    } catch (e) {
      print('ADMIN CHECK RESULT: Error in isAdmin(): $e, user is NOT ADMIN');
      _updateAdminCache(false);
      return false;
    } finally {
      print('=====================');
    }
  }
  
  // Hàm cập nhật cache
  void _updateAdminCache(bool status) {
    _cachedAdminStatus = status;
    _cachedAdminStatusTime = DateTime.now();
    print('Updated admin status cache: $status');
  }
  
  // Kiểm tra admin bỏ qua cache
  Future<bool> forceAdminCheck() async {
    // Reset cache trước
    _cachedAdminStatus = null;
    _cachedAdminStatusTime = null;
    print('Force admin check - ignoring cache');
    
    // Gọi isAdmin bình thường
    return isAdmin();
  }
} 