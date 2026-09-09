import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Đổi thành true để trỏ về máy chủ chạy trên máy dev khi dùng emulator
  // Android. Chỉ có tác dụng khi .env không khai báo API_BASE_URL.
  static const bool useEmulator = false;

  // URL dự phòng cho các môi trường khác nhau
  static const String _emulatorBaseUrl = 'http://10.0.2.2:5000/api/v1'; // Localhost trên emulator
  static const String _physicalDeviceBaseUrl = 'http://103.27.239.248:3000/api/v1'; // Máy chủ mặc định

  /// Địa chỉ gốc của API.
  ///
  /// Ưu tiên `API_BASE_URL` trong .env để đổi máy chủ mà không phải sửa mã
  /// nguồn và build lại — hữu ích khi chuyển giữa máy dev, staging và
  /// production, hoặc khi máy chủ mặc định đổi địa chỉ. Nếu biến này không có
  /// thì quay về hằng số dự phòng như trước.
  static String get baseUrl {
    if (dotenv.isInitialized) {
      final fromEnv = dotenv.env['API_BASE_URL'];
      if (fromEnv != null && fromEnv.isNotEmpty) {
        // Bỏ dấu '/' thừa ở cuối để nối endpoint không sinh ra '//'
        return fromEnv.endsWith('/')
            ? fromEnv.substring(0, fromEnv.length - 1)
            : fromEnv;
      }
    }
    return useEmulator ? _emulatorBaseUrl : _physicalDeviceBaseUrl;
  }

  // Các endpoint cụ thể
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get refreshToken => '$baseUrl/auth/refresh-token';
  static String get logout => '$baseUrl/auth/logout';
  static String get profile => '$baseUrl/auth/me';
  static String get changePassword => '$baseUrl/users/change-password';
  static String get updateProfile => '$baseUrl/users/update-profile';
  static String get users => '$baseUrl/auth/users';

  // Endpoint cho quản lý rác thải
  static String get wasteTypes => '$baseUrl/waste-types';
  static String get collectionPoints => '$baseUrl/collection-points';
  static String get transactions => '$baseUrl/transactions';
  static String get schedules => '$baseUrl/waste/schedules';
  static String get rewards => '$baseUrl/rewards';
  static String get recyclingStatistics => '$baseUrl/recycling/statistics';

  // Endpoint mới phát hiện trong quá trình rà soát
  // Endpoint liên quan đến giao dịch
  static String get myTransactions => '$baseUrl/transactions/my-transactions';
  
  // Endpoint for file uploads
  static String get upload => '$baseUrl/upload';
  
  // Endpoint liên quan đến điểm thu gom và loại rác
  static String wasteTypeDetail(int id) => '$baseUrl/waste-types/$id';
  static String collectionPointDetail(int id) => '$baseUrl/collection-points/$id';
  static String get wasteTypeCollectionPoint => '$baseUrl/waste-types/collection-point';
  static String wasteTypesForCollectionPoint(int collectionPointId) => '$baseUrl/waste-types/collection-point/$collectionPointId';
  
  // Endpoint liên quan đến tái chế
  static String get recycling => '$baseUrl/recycling';
  static String get recyclingAll => '$baseUrl/recycling/all';
  static String recyclingDetail(String id) => '$baseUrl/recycling/$id';
  static String get recyclingReport => '$baseUrl/recycling/report';
}