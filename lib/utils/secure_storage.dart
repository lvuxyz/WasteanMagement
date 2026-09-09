import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'storage_keys.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: SecureStorageKeys.token, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: SecureStorageKeys.token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: SecureStorageKeys.token);
  }

  Future<void> saveUser(User user) async {
    await _storage.write(
      key: SecureStorageKeys.user,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<User?> getUser() async {
    final userJson = await _storage.read(key: SecureStorageKeys.user);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: SecureStorageKeys.user);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
} 

