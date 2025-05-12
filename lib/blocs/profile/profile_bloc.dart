import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_constants.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthService _authService = AuthService();
  
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      
      // Get the auth token
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }
      
      // Make API request
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (responseData['success'] == true && responseData['data'] != null) {
          final userProfile = UserProfile.fromJson(responseData['data']);
          emit(ProfileLoaded(userProfile: userProfile));
        } else {
          emit(const ProfileError('Không thể tải thông tin người dùng'));
        }
      } else {
        // Error handling
        final errorMessage = responseData['message'] ?? 'Lỗi khi tải thông tin người dùng';
        emit(ProfileError(errorMessage));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      
      // Get the auth token
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }
      
      // Make API request to update profile
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'full_name': event.fullName,
          'email': event.email,
          'phone': event.phone,
          'address': event.address,
        }),
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          emit(const ProfileUpdateSuccess());
          // Reload profile after successful update
          add(LoadProfile());
        } else {
          emit(ProfileError(responseData['message'] ?? 'Lỗi cập nhật thông tin'));
        }
      } else {
        // Error handling
        final errorMessage = responseData['message'] ?? 'Lỗi cập nhật thông tin người dùng';
        emit(ProfileError(errorMessage));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}