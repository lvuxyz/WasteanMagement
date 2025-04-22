import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasteanmagement/utils/storage_keys.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';

class LocalDataSource {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Token management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: SecureStorageKeys.token, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: SecureStorageKeys.token);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: SecureStorageKeys.token);
  }

  // User profile management
  Future<void> cacheUserProfile(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(PreferenceKeys.userProfile, userJson);
  }

  Future<User?> getCachedUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(PreferenceKeys.userProfile);

    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }

    return null;
  }

  Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PreferenceKeys.userProfile);
  }

  // Language preferences
  Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PreferenceKeys.languageCode) ?? 'en';
  }

  Future<bool> setLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(PreferenceKeys.languageCode, languageCode);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}