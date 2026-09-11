import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // ===========================================================================
  // CHỌN MÁY CHỦ
  // Bỏ comment ĐÚNG MỘT dòng `_selectedBaseUrl` bên dưới, comment dòng còn lại.
  // Cả hai địa chỉ đều được giữ nguyên ở phần "Danh sách máy chủ" phía dưới,
  // nên đổi qua lại không mất cấu hình nào.
  // ===========================================================================

  // >>> ĐANG DÙNG: API local trên máy dev.
  static const String _selectedBaseUrl = _localBaseUrl;

  // >>> API đã đẩy lên server. Bỏ comment dòng này (và comment dòng trên) khi
  //     muốn quay lại chạy với máy chủ thật.
  // static const String _selectedBaseUrl = _remoteBaseUrl;

  // ---------------------------------------------------------------------------
  // Danh sách máy chủ — giữ nguyên cả hai, không xóa dòng nào.
  // ---------------------------------------------------------------------------

  /// API chạy local trên máy dev.
  ///
  /// Đang để IP LAN vì máy Android thật không hiểu `localhost` lẫn `10.0.2.2`.
  /// Đổi lại khi máy dev sang mạng khác (xem IP bằng `ipconfig`). Nếu chỉ chạy
  /// trên emulator hoặc desktop thì đặt `http://localhost:5001/api/v1` cũng
  /// được: [_resolveLoopback] tự đổi sang `10.0.2.2` khi build Android.
  // ignore: unused_field
  static const String _localBaseUrl = 'http://192.168.1.3:5001/api/v1';

  /// API đã đẩy lên server.
  // ignore: unused_field
  static const String _remoteBaseUrl = 'http://103.27.239.248:3000/api/v1';

  /// Địa chỉ gốc của API.
  ///
  /// Mặc định lấy theo [_selectedBaseUrl] ngay trong file này. `API_BASE_URL`
  /// trong .env vẫn được ưu tiên cao hơn để đổi máy chủ lúc chạy mà không phải
  /// build lại — bỏ trống biến đó (mặc định) nếu muốn file này toàn quyền
  /// quyết định.
  static String get baseUrl {
    if (dotenv.isInitialized) {
      final fromEnv = dotenv.env['API_BASE_URL'];
      if (fromEnv != null && fromEnv.isNotEmpty) {
        // Bỏ dấu '/' thừa ở cuối để nối endpoint không sinh ra '//'
        final trimmed = fromEnv.endsWith('/')
            ? fromEnv.substring(0, fromEnv.length - 1)
            : fromEnv;
        return _resolveLoopback(trimmed);
      }
    }
    return _resolveLoopback(_selectedBaseUrl);
  }

  /// Đổi `localhost`/`127.0.0.1` thành `10.0.2.2` khi chạy trên Android.
  ///
  /// Trong emulator Android, `localhost` là chính máy ảo chứ không phải máy
  /// dev, nên API chạy local sẽ không kết nối được. `10.0.2.2` là alias mà
  /// emulator dành riêng cho host. Nhờ vậy cùng một hằng số dùng được cho cả
  /// web, desktop lẫn emulator mà không phải sửa lại.
  static String _resolveLoopback(String url) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return url;
    return url
        .replaceFirst('//localhost', '//10.0.2.2')
        .replaceFirst('//127.0.0.1', '//10.0.2.2');
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