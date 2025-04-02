import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'constants.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: ApiConstants.tokenKey);
  }

  Future<void> saveUser(User user) async {
    await _storage.write(
      key: ApiConstants.userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<User?> getUser() async {
    final userJson = await _storage.read(key: ApiConstants.userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: ApiConstants.userKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
} 