import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/storage_keys.dart';
import '../utils/app_logger.dart';

class AuthService {
  static const String _tag = 'Auth';
  static const Duration _adminCacheTtl = Duration(seconds: 10);
  static const String _tokenKey = SecureStorageKeys.token;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Cache cho admin status
  bool? _cachedAdminStatus;
  DateTime? _cachedAdminStatusTime;

  Future<String?> getToken() async {
    try {
      // Không log ở đây: hàm được gọi trước gần như mọi request nên mỗi lần
      // log sẽ nhân đôi số dòng của một lượt gọi API mà không thêm thông tin.
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      AppLogger.e(_tag, 'Không đọc được token từ secure storage', error: e);
      return null;
    }
  }

  /// Kiểm tra quyền admin dựa trên `roles` trong payload của JWT.
  ///
  /// Toàn bộ nhánh xử lý đều kết thúc bằng đúng một dòng log dạng
  /// `admin=<true/false> · <lý do>` thay vì bộ khung `===== ADMIN CHECK =====`
  /// ba dòng như trước.
  Future<bool> isAdmin() async {
    final now = DateTime.now();
    final cachedAt = _cachedAdminStatusTime;
    if (_cachedAdminStatus != null && cachedAt != null) {
      final age = now.difference(cachedAt);
      if (age < _adminCacheTtl) {
        AppLogger.d(
          _tag,
          'admin=$_cachedAdminStatus · lấy từ cache (${age.inSeconds}s trước)',
        );
        return _cachedAdminStatus!;
      }
    }

    try {
      final token = await getToken();
      if (token == null) {
        return _resolveAdmin(false, 'chưa có token');
      }

      final parts = token.split('.');
      if (parts.length != 3) {
        return _resolveAdmin(false, 'token sai định dạng JWT (${parts.length} phần)');
      }

      final decoded = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payload = json.decode(decoded);

      if (payload is! Map || payload['roles'] is! List) {
        return _resolveAdmin(false, 'payload JWT không có mảng roles');
      }

      final roles = List<String>.from(payload['roles']);
      final isAdmin = roles.any((role) => role.toLowerCase() == 'admin');
      return _resolveAdmin(
        isAdmin,
        'roles=${roles.isEmpty ? '[]' : roles.join(',')}, '
        'userId=${payload['userId']}, username=${payload['username']}',
      );
    } catch (e) {
      AppLogger.e(_tag, 'Không đọc được quyền admin từ token', error: e);
      _updateAdminCache(false);
      return false;
    }
  }

  /// Ghi cache và in đúng một dòng kết luận cho lần kiểm tra quyền.
  bool _resolveAdmin(bool isAdmin, String reason) {
    _updateAdminCache(isAdmin);
    AppLogger.i(_tag, 'admin=$isAdmin · $reason');
    return isAdmin;
  }

  void _updateAdminCache(bool status) {
    _cachedAdminStatus = status;
    _cachedAdminStatusTime = DateTime.now();
  }

  // Kiểm tra admin bỏ qua cache
  Future<bool> forceAdminCheck() async {
    _cachedAdminStatus = null;
    _cachedAdminStatusTime = null;
    AppLogger.d(_tag, 'Kiểm tra lại quyền admin, bỏ qua cache');
    return isAdmin();
  }
}
