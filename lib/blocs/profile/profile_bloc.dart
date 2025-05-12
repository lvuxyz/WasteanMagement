import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_constants.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../repositories/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthService _authService = AuthService();
  final UserRepository? userRepository;
  
  ProfileBloc({this.userRepository}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      
      if (userRepository != null) {
        try {
          // If we have a userRepository, use it to get the profile
          final user = await userRepository!.getUserProfile();
          
          // If user has rawProfileData, it means we already have the full profile data
          if (user.rawProfileData != null) {
            // Create UserProfile from the raw data
            final userProfile = UserProfile.fromJson(user.rawProfileData!);
            emit(ProfileLoaded(userProfile: userProfile));
            return;
          }
          
          // Convert the User to UserProfile
          final userProfile = UserProfile.fromUserModel(user);
          emit(ProfileLoaded(userProfile: userProfile));
          return;
        } catch (repoError) {
          // If using userRepository fails, fall back to the direct API call
          print('UserRepository error: $repoError. Falling back to direct API call.');
        }
      }
      
      // Fall back to original implementation using AuthService
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }
      
      // Make API request
      final response = await http.get(
        Uri.parse(ApiConstants.profile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (responseData['success'] == true && responseData['data'] != null) {
          // Use the provided data structure from the response
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
      
      // Try to use userRepository if available
      if (userRepository != null) {
        try {
          await userRepository!.updateUserProfile(
            fullName: event.fullName,
            email: event.email,
            phone: event.phone,
            address: event.address,
          );
          
          emit(const ProfileUpdateSuccess());
          // Reload profile after successful update
          add(LoadProfile());
          return;
        } catch (repoError) {
          // If repository fails, try the direct API approach
          print('UserRepository update error: $repoError. Falling back to direct API call.');
        }
      }
      
      // Fall back to original implementation using AuthService
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }
      
      // Make API request to update profile
      final response = await http.put(
        Uri.parse(ApiConstants.updateProfile),
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
          emit(ProfileError(responseData['message'] ?? 'Cập nhật thông tin thất bại'));
        }
      } else {
        emit(ProfileError(responseData['message'] ?? 'Lỗi khi cập nhật thông tin người dùng'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}