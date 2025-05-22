import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../core/api/api_constants.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../repositories/user_repository.dart';
import 'user_profile_event.dart';
import 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final AuthService _authService = AuthService();
  final UserRepository? userRepository;
  
  // Add cache variables
  UserProfile? _cachedProfile;
  DateTime? _lastFetchTime;
  static const int _cacheDurationSeconds = 10; // Cache valid for 10 seconds
  
  UserProfileBloc({this.userRepository}) : super(UserProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<RefreshUserProfile>(_onRefreshUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      emit(UserProfileLoading());
      final userProfile = await _getUserProfile();
      emit(UserProfileLoaded(userProfile));
    } catch (e) {
      developer.log('Error fetching user profile: $e');
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onRefreshUserProfile(
    RefreshUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      // If we have a current state with profile data, show refreshing with current data
      if (state is UserProfileLoaded) {
        emit(UserProfileRefreshing((state as UserProfileLoaded).userProfile));
      } else {
        emit(UserProfileLoading());
      }
      
      final userProfile = await _getUserProfile();
      emit(UserProfileLoaded(userProfile));
    } catch (e) {
      developer.log('Error refreshing user profile: $e');
      // If refresh fails but we already had data, go back to loaded state
      if (state is UserProfileRefreshing) {
        emit(UserProfileLoaded((state as UserProfileRefreshing).userProfile));
      } else {
        emit(UserProfileError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      // Keep current profile data while updating
      if (state is UserProfileLoaded) {
        emit(UserProfileRefreshing((state as UserProfileLoaded).userProfile));
      } else {
        emit(UserProfileLoading());
      }
      
      // Try to use userRepository if available
      if (userRepository != null) {
        try {
          await userRepository!.updateUserProfile(
            fullName: event.fullName,
            email: event.email,
            phone: event.phone,
            address: event.address,
          );
          
          emit(const UserProfileUpdateSuccess());
          // Reload profile after successful update
          add(const RefreshUserProfile());
          return;
        } catch (repoError) {
          developer.log('UserRepository update error: $repoError. Falling back to direct API call.');
        }
      }
      
      // Fall back to direct API call
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }
      
      // Make API request to update profile
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          if (event.fullName != null) 'full_name': event.fullName,
          if (event.email != null) 'email': event.email,
          if (event.phone != null) 'phone': event.phone,
          if (event.address != null) 'address': event.address,
        }),
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          emit(const UserProfileUpdateSuccess());
          // Reload profile after successful update
          add(const RefreshUserProfile());
        } else {
          emit(UserProfileError(responseData['message'] ?? 'Cập nhật thông tin thất bại'));
        }
      } else {
        emit(UserProfileError(responseData['message'] ?? 'Lỗi khi cập nhật thông tin người dùng'));
      }
    } catch (e) {
      developer.log('Error updating user profile: $e');
      emit(UserProfileError(e.toString()));
    }
  }

  /// Helper method to get user profile from repository or API
  Future<UserProfile> _getUserProfile() async {
    final now = DateTime.now();
    
    // Check if we have a valid cache
    if (_cachedProfile != null && _lastFetchTime != null) {
      final cacheDuration = now.difference(_lastFetchTime!);
      if (cacheDuration.inSeconds < _cacheDurationSeconds) {
        developer.log('Using cached user profile (cache age: ${cacheDuration.inSeconds}s)');
        return _cachedProfile!;
      }
    }
    
    // No valid cache, fetch from repository or API
    developer.log('Fetching fresh user profile data');
    
    if (userRepository != null) {
      try {
        final user = await userRepository!.getUserProfile();
        
        // If user has rawProfileData, it means we already have the full profile data
        if (user.rawProfileData != null) {
          // Create UserProfile from the raw data
          final profile = UserProfile.fromJson(user.rawProfileData!);
          _updateCache(profile);
          return profile;
        }
        
        // Convert the User to UserProfile
        final profile = UserProfile.fromUserModel(user);
        _updateCache(profile);
        return profile;
      } catch (repoError) {
        developer.log('UserRepository error: $repoError. Falling back to direct API call.');
      }
    }
    
    // Fall back to direct API call
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token xác thực');
    }
    
    // Make API request
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/me'), // Updated endpoint as specified
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    final responseData = json.decode(response.body);
    
    if (response.statusCode == 200) {
      if (responseData['success'] == true && responseData['data'] != null) {
        // Use the provided data structure from the response
        final profile = UserProfile.fromJson(responseData['data']);
        _updateCache(profile);
        return profile;
      } else {
        throw Exception('Không thể tải thông tin người dùng');
      }
    } else {
      // Error handling
      final errorMessage = responseData['message'] ?? 'Lỗi khi tải thông tin người dùng';
      throw Exception(errorMessage);
    }
  }
  
  // Helper method to update the cache
  void _updateCache(UserProfile profile) {
    _cachedProfile = profile;
    _lastFetchTime = DateTime.now();
    developer.log('Updated user profile cache');
  }
} 