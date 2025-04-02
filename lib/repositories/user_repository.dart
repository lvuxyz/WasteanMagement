import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/secure_storage.dart';

class UserRepository {
  final String baseUrl = ApiConstants.baseUrl;
  final SecureStorage secureStorage = SecureStorage();
  
  // Flag for using mock data during development
  final bool useMockData = true;

  Future<User> getUserProfile() async {
    if (useMockData) {
      // Return mock data for development
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      return User(
        id: '1',
        email: 'user@example.com',
        username: 'user123',
        fullName: 'John Doe',
        phone: '+84 123 456 789',
        address: '123 Green Street, Hanoi, Vietnam',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      );
    }
    
    try {
      final token = await secureStorage.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<User> updateUserProfile({
    String? fullName,
    String? email,
    String? phone,
    String? address,
  }) async {
    if (useMockData) {
      // Return mock data for development
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      return User(
        id: '1',
        email: email ?? 'user@example.com',
        username: 'user123',
        fullName: fullName ?? 'John Doe',
        phone: phone ?? '+84 123 456 789',
        address: address ?? '123 Green Street, Hanoi, Vietnam',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      );
    }
    
    try {
      final token = await secureStorage.getToken();
      final Map<String, dynamic> requestBody = {};

      if (fullName != null) requestBody['full_name'] = fullName;
      if (email != null) requestBody['email'] = email;
      if (phone != null) requestBody['phone'] = phone;
      if (address != null) requestBody['address'] = address;

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to update user profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
} 