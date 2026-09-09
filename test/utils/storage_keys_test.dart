import 'package:flutter_test/flutter_test.dart';
import 'package:wasteanmagement/utils/storage_keys.dart';

void main() {
  group('SecureStorageKeys', () {
    // Các chuỗi này là khóa thật trên thiết bị người dùng. Đổi chúng đồng
    // nghĩa với việc app không đọc được token và hồ sơ đã lưu, tức đăng xuất
    // toàn bộ người dùng hiện có mà không có lỗi nào báo ra. Nếu buộc phải
    // đổi thì phải kèm bước di trú dữ liệu, và test này phải đổi theo một
    // cách có chủ đích.
    test('giữ nguyên giá trị khóa đang dùng trên thiết bị', () {
      expect(SecureStorageKeys.token, 'auth_token');
      expect(SecureStorageKeys.refreshToken, 'refresh_token');
      expect(SecureStorageKeys.user, 'user_data');
    });

    test('các khóa không trùng nhau', () {
      const keys = [
        SecureStorageKeys.token,
        SecureStorageKeys.refreshToken,
        SecureStorageKeys.user,
      ];

      expect(keys.toSet(), hasLength(keys.length));
    });
  });

  group('PreferenceKeys', () {
    test('giữ nguyên giá trị khóa đang dùng trên thiết bị', () {
      expect(PreferenceKeys.userProfile, 'user_profile');
      expect(PreferenceKeys.languageCode, 'language_code');
      expect(PreferenceKeys.isDarkMode, 'is_dark_mode');
    });
  });
}
