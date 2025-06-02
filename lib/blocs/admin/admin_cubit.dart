import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/user_repository.dart';
import 'dart:developer' as developer;
import 'dart:convert';

class AdminCubit extends Cubit<bool> {
  final UserRepository userRepository;
  
  AdminCubit({required this.userRepository}) : super(false);
  
  Future<void> checkAdminStatus() async {
    try {
      developer.log('Checking admin status...');
      final user = await userRepository.getUserProfile();
      
      // Attempt to extract roles from JWT token
      final token = await userRepository.localDataSource.getToken();
      bool hasAdminRoleFromToken = false;
      
      if (token != null) {
        try {
          // Parse JWT token payload (middle part)
          final parts = token.split('.');
          if (parts.length > 1) {
            // Base64 decode and parse as JSON
            String normalizedBase64 = parts[1].replaceAll('-', '+').replaceAll('_', '/');
            // Pad the base64 string if needed
            while (normalizedBase64.length % 4 != 0) {
              normalizedBase64 += '=';
            }
            
            final jsonPayload = utf8.decode(base64Url.decode(normalizedBase64));
            final payload = json.decode(jsonPayload);
            
            final List<dynamic>? tokenRoles = payload['roles'];
            if (tokenRoles != null) {
              developer.log('JWT payload: $payload');
              developer.log('Roles from JWT token: $tokenRoles');
              hasAdminRoleFromToken = tokenRoles.any((role) => 
                role.toString().toLowerCase() == 'admin');
              
              if (hasAdminRoleFromToken) {
                developer.log('ADMIN ROLE FOUND IN JWT TOKEN!');
              }
            }
          }
        } catch (e) {
          developer.log('Error parsing JWT token: $e');
        }
      }
      
      // Get the raw profile data too
      final rawData = user.rawProfileData;
      developer.log('Raw profile data: ${rawData != null ? "available" : "null"}');
      
      // Check roles from basic info too
      List<String>? basicInfoRoles;
      if (rawData != null && rawData['basic_info'] != null) {
        final basicInfo = rawData['basic_info'];
        if (basicInfo['roles'] != null) {
          basicInfoRoles = List<String>.from(basicInfo['roles']);
          developer.log('Roles from basic_info: $basicInfoRoles');
        }
      }
      
      // Detailed logging
      developer.log('User roles from User.roles: ${user.roles ?? "null"}');
      developer.log('User roles from basicInfo: ${basicInfoRoles ?? "null"}');
      developer.log('isAdmin from JWT token: $hasAdminRoleFromToken');
      
      // Check admin status from all sources
      final bool isAdminFromProperty = user.isAdmin;
      final bool hasAdminRoleFromUserObject = (user.roles?.any((role) => 
          role.toLowerCase() == 'admin') ?? false);
      final bool hasAdminRoleFromBasicInfo = (basicInfoRoles?.any((role) => 
          role.toLowerCase() == 'admin') ?? false);
          
      final bool finalIsAdmin = isAdminFromProperty || 
                               hasAdminRoleFromUserObject || 
                               hasAdminRoleFromBasicInfo || 
                               hasAdminRoleFromToken;
          
      developer.log('Admin check summary:');
      developer.log('- isAdminFromProperty: $isAdminFromProperty');
      developer.log('- hasAdminRoleFromUserObject: $hasAdminRoleFromUserObject');
      developer.log('- hasAdminRoleFromBasicInfo: $hasAdminRoleFromBasicInfo');
      developer.log('- hasAdminRoleFromToken: $hasAdminRoleFromToken');
      developer.log('Final admin status to emit: $finalIsAdmin');
      
      emit(finalIsAdmin);
      developer.log('User admin status emitted: $finalIsAdmin');
      
      // Cache the admin status for other services/cubit to use
      developer.log('Updated admin status cache: $finalIsAdmin');
    } catch (e) {
      developer.log('Error checking admin privileges: $e', error: e);
      // More detailed logging
      developer.log('Stack trace: ${StackTrace.current}');
      // Don't change current state on error
      emit(false);
    }
  }
  
  // Method to force update admin status
  // IMPORTANT: This should ONLY be used for testing purposes and NEVER in production code.
  // Using this method to bypass authentication is a serious security risk.
  void forceUpdateAdminStatus(bool isAdmin) {
    developer.log('Force updating admin status to: $isAdmin - THIS SHOULD ONLY BE USED FOR TESTING', error: isAdmin ? null : 'Security warning: Setting admin to false is safer');
    emit(isAdmin);
  }
  
  // Method to clear admin status when logging out
  void clearAdminStatus() {
    developer.log('Clearing admin status on logout');
    emit(false);
  }
} 