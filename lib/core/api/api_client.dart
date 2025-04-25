import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import '../error/exceptions.dart';
import './api_response.dart';
import '../../utils/secure_storage.dart';

class ApiClient {
  final http.Client client;
  final SecureStorage secureStorage;

  ApiClient({
    required this.client,
    required this.secureStorage,
  });

  // GET request
  Future<ApiResponse> get(String url, {Map<String, String>? headers}) async {
    try {
      developer.log('Đang gửi GET request đến: $url');
      final token = await secureStorage.getToken();
      
      if (token != null) {
        developer.log('Auth token được sử dụng: ${token.substring(0, math.min(10, token.length))}...');
      } else {
        developer.log('Không có token xác thực');
      }
      
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      developer.log('Headers: $requestHeaders');

      final response = await client.get(
        Uri.parse(url),
        headers: requestHeaders,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          developer.log('Timeout khi kết nối tới $url', error: 'Request timeout');
          throw NetworkException('Kết nối tới máy chủ quá thời gian. Vui lòng thử lại sau.');
        },
      );

      developer.log('Đã nhận phản hồi từ $url với mã: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 400) {
        developer.log('Phản hồi thành công, độ dài nội dung: ${response.body.length}');
      } else {
        developer.log('Phản hồi lỗi: ${response.statusCode} - ${response.body}', error: 'API Error');
      }

      return _processResponse(response);
    } catch (e) {
      developer.log('Lỗi kết nối: ${e.toString()}', error: e);
      throw NetworkException('Không thể kết nối đến máy chủ: ${e.toString()}');
    }
  }

  // POST request
  Future<ApiResponse> post(String url, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      final token = await secureStorage.getToken();
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      final response = await client.post(
        Uri.parse(url),
        body: body != null ? json.encode(body) : null,
        headers: requestHeaders,
      );

      return _processResponse(response);
    } catch (e) {
      throw NetworkException('Không thể kết nối đến máy chủ: ${e.toString()}');
    }
  }

  // PUT request
  Future<ApiResponse> put(String url, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      final token = await secureStorage.getToken();
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      final response = await client.put(
        Uri.parse(url),
        body: body != null ? json.encode(body) : null,
        headers: requestHeaders,
      );

      return _processResponse(response);
    } catch (e) {
      throw NetworkException('Không thể kết nối đến máy chủ: ${e.toString()}');
    }
  }

  // DELETE request
  Future<ApiResponse> delete(String url, {Map<String, String>? headers}) async {
    try {
      final token = await secureStorage.getToken();
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      final response = await client.delete(
        Uri.parse(url),
        headers: requestHeaders,
      );

      return _processResponse(response);
    } catch (e) {
      throw NetworkException('Không thể kết nối đến máy chủ: ${e.toString()}');
    }
  }

  // Xử lý phản hồi
  ApiResponse _processResponse(http.Response response) {
    developer.log('Đang xử lý phản hồi với mã: ${response.statusCode}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Thành công
      Map<String, dynamic> responseData;
      try {
        if (response.body.isEmpty) {
          developer.log('Phản hồi rỗng từ server');
          responseData = {'message': 'Thành công', 'success': true};
        } else {
          developer.log('Đang phân tích phản hồi JSON: ${response.body.substring(0, math.min(200, response.body.length))}...');
          responseData = json.decode(response.body);
          developer.log('Phân tích JSON thành công');
        }
      } catch (e) {
        developer.log('Lỗi phân tích dữ liệu JSON: ${e.toString()}', error: e);
        developer.log('Nội dung gây lỗi: ${response.body.substring(0, math.min(200, response.body.length))}...');
        responseData = {'message': 'Lỗi phân tích dữ liệu phản hồi', 'success': false};
      }

      return ApiResponse(
        statusCode: response.statusCode,
        data: responseData,
      );
    } else if (response.statusCode == 401) {
      // Không được phép
      developer.log('Lỗi 401 Unauthorized', error: 'Auth Error');
      throw UnauthorizedException('Phiên đăng nhập hết hạn hoặc không hợp lệ');
    } else if (response.statusCode == 403) {
      // Bị cấm truy cập
      developer.log('Lỗi 403 Forbidden', error: 'Auth Error');
      throw UnauthorizedException('Không có quyền truy cập tài nguyên này');
    } else if (response.statusCode == 404) {
      // Không tìm thấy
      developer.log('Lỗi 404 Not Found: ${response.body}', error: 'Not Found');
      throw ServerException('Không tìm thấy tài nguyên yêu cầu');
    } else {
      // Lỗi khác
      try {
        developer.log('Lỗi server ${response.statusCode}: ${response.body}', error: 'Server Error');
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Đã xảy ra lỗi';
        throw ServerException(errorMessage);
      } catch (e) {
        developer.log('Lỗi khi xử lý phản hồi lỗi: ${e.toString()}', error: e);
        throw ServerException('Đã xảy ra lỗi: ${response.statusCode} - ${response.body}');
      }
    }
  }
}