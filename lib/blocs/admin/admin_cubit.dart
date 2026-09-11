import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/user_repository.dart';
import 'dart:convert';
import '../../utils/app_logger.dart';

class AdminCubit extends Cubit<bool> {
  static const String _tag = 'Admin';

  final UserRepository userRepository;

  AdminCubit({required this.userRepository}) : super(false);

  Future<void> checkAdminStatus() async {
    try {
      AppLogger.d(_tag, 'Bắt đầu kiểm tra quyền admin');
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
              hasAdminRoleFromToken = tokenRoles.any((role) =>
                role.toString().toLowerCase() == 'admin');
            }
          }
        } catch (e) {
          AppLogger.w(_tag, 'Không đọc được payload JWT: $e');
        }
      }

      // Get the raw profile data too
      final rawData = user.rawProfileData;

      // Check roles from basic info too
      List<String>? basicInfoRoles;
      if (rawData != null && rawData['basic_info'] != null) {
        final basicInfo = rawData['basic_info'];
        if (basicInfo['roles'] != null) {
          basicInfoRoles = List<String>.from(basicInfo['roles']);
        }
      }

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

      // Một dòng duy nhất cho cả lần kiểm tra: kết luận đứng trước, nguồn nào
      // xác nhận quyền admin đứng sau để còn lần ra khi kết quả bất thường.
      AppLogger.i(
        _tag,
        'admin=$finalIsAdmin · user.isAdmin=$isAdminFromProperty, '
        'user.roles=${user.roles ?? const []}, '
        'basic_info.roles=${basicInfoRoles ?? const []}, '
        'jwt=$hasAdminRoleFromToken',
      );
      emit(finalIsAdmin);
    } catch (e, stackTrace) {
      AppLogger.e(_tag, 'Không kiểm tra được quyền admin',
          error: e, stackTrace: stackTrace);
      // Don't change current state on error
      emit(false);
    }
  }

  // Method to force update admin status
  // IMPORTANT: This should ONLY be used for testing purposes and NEVER in production code.
  // Using this method to bypass authentication is a serious security risk.
  void forceUpdateAdminStatus(bool isAdmin) {
    AppLogger.w(_tag,
        'Ép quyền admin=$isAdmin — CHỈ dùng khi test, không dùng ở bản phát hành');
    emit(isAdmin);
  }

  // Method to clear admin status when logging out
  void clearAdminStatus() {
    AppLogger.d(_tag, 'Xóa trạng thái admin khi đăng xuất');
    emit(false);
  }
} 