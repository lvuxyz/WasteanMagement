import 'dart:convert';
import 'package:http/http.dart' as http;
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
      final token = await secureStorage.getToken();
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      final response = await client.get(
        Uri.parse(url),
        headers: requestHeaders,
      );

      return _processResponse(response);
    } catch (e) {
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
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Thành công
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        responseData = {'message': 'Lỗi phân tích dữ liệu phản hồi'};
      }

      return ApiResponse(
        statusCode: response.statusCode,
        data: responseData,
      );
    } else if (response.statusCode == 401) {
      // Không được phép
      throw UnauthorizedException('Phiên đăng nhập hết hạn hoặc không hợp lệ');
    } else if (response.statusCode == 403) {
      // Bị cấm truy cập
      throw UnauthorizedException('Không có quyền truy cập tài nguyên này');
    } else if (response.statusCode == 404) {
      // Không tìm thấy
      throw ServerException('Không tìm thấy tài nguyên yêu cầu');
    } else {
      // Lỗi khác
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Đã xảy ra lỗi';
        throw ServerException(errorMessage);
      } catch (e) {
        throw ServerException('Đã xảy ra lỗi: ${response.statusCode} - ${response.body}');
      }
    }
  }
}