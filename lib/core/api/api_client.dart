import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';
import './api_response.dart';
import '../../utils/app_logger.dart';
import '../../utils/secure_storage.dart';

class ApiClient {
  static const String _tag = 'API';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client client;
  final SecureStorage secureStorage;

  ApiClient({
    required this.client,
    required this.secureStorage,
  });

  Future<ApiResponse> get(String url, {Map<String, String>? headers}) =>
      _send('GET', url, headers: headers);

  Future<ApiResponse> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) =>
      _send('POST', url, body: body, headers: headers);

  Future<ApiResponse> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) =>
      _send('PUT', url, body: body, headers: headers);

  Future<ApiResponse> patch(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) =>
      _send('PATCH', url, body: body, headers: headers);

  Future<ApiResponse> delete(String url, {Map<String, String>? headers}) =>
      _send('DELETE', url, headers: headers);

  /// Điểm đi qua duy nhất của mọi request.
  ///
  /// Gom về một chỗ để mỗi lượt gọi API chỉ sinh đúng hai dòng log — một dòng
  /// `→` lúc gửi và một dòng `←`/`x` lúc nhận — thay vì mỗi HTTP method tự log
  /// theo một kiểu (trước đây GET/PATCH log rất nhiều còn POST/PUT/DELETE thì
  /// im lặng hoàn toàn).
  Future<ApiResponse> _send(
    String method,
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    AppLogger.request(method, url, body: body);
    final stopwatch = Stopwatch()..start();

    http.Response response;
    try {
      final requestHeaders = await _buildHeaders(headers);
      final uri = Uri.parse(url);
      final encodedBody = body == null ? null : json.encode(body);

      final future = switch (method) {
        'GET' => client.get(uri, headers: requestHeaders),
        'POST' =>
          client.post(uri, headers: requestHeaders, body: encodedBody),
        'PUT' => client.put(uri, headers: requestHeaders, body: encodedBody),
        'PATCH' =>
          client.patch(uri, headers: requestHeaders, body: encodedBody),
        'DELETE' => client.delete(uri, headers: requestHeaders),
        _ => throw ServerException('HTTP method không được hỗ trợ: $method'),
      };

      response = await future.timeout(
        _timeout,
        onTimeout: () => throw NetworkException(
          'Kết nối tới máy chủ quá thời gian (${_timeout.inSeconds}s). '
          'Vui lòng thử lại sau.',
        ),
      );
    } on NetworkException catch (error) {
      AppLogger.w(
        _tag,
        'x $method ${AppLogger.shortUrl(url)} '
        '(${stopwatch.elapsedMilliseconds}ms) · ${error.message}',
      );
      rethrow;
    } catch (error) {
      AppLogger.e(
        _tag,
        'x $method ${AppLogger.shortUrl(url)} '
        '(${stopwatch.elapsedMilliseconds}ms) · không gửi được request',
        error: error,
      );
      throw NetworkException('Không thể kết nối đến máy chủ: $error');
    }

    AppLogger.response(
      method,
      url,
      response.statusCode,
      elapsedMs: stopwatch.elapsedMilliseconds,
      bodyLength: response.bodyBytes.length,
      errorMessage: response.statusCode >= 400
          ? _extractErrorMessage(response.body)
          : null,
    );

    return _processResponse(response);
  }

  Future<Map<String, String>> _buildHeaders(Map<String, String>? extra) async {
    final token = await secureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?extra,
    };
  }

  /// Chuyển phản hồi HTTP thành [ApiResponse] hoặc ném exception tương ứng.
  ///
  /// Không log ở đây: mọi thông tin về mã trạng thái và lỗi của server đã nằm
  /// trong dòng `←`/`x` mà [_send] in ra ngay trước đó.
  ApiResponse _processResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse(
        statusCode: statusCode,
        data: _decodeBody(response),
      );
    }

    final serverMessage = _extractErrorMessage(response.body);

    switch (statusCode) {
      case 401:
        throw UnauthorizedException(
          serverMessage ?? 'Phiên đăng nhập hết hạn hoặc không hợp lệ',
        );
      case 403:
        throw UnauthorizedException(
          serverMessage ?? 'Không có quyền truy cập tài nguyên này',
        );
      case 404:
        throw ServerException(
          serverMessage ?? 'Không tìm thấy tài nguyên yêu cầu',
        );
      default:
        throw ServerException(
          serverMessage ?? 'Máy chủ trả về lỗi $statusCode',
        );
    }
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return {'message': 'Thành công', 'success': true};
    }
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded, 'success': true};
    } catch (error) {
      AppLogger.e(
        _tag,
        'Không phân tích được JSON trả về · ${AppLogger.preview(response.body)}',
        error: error,
      );
      return {'message': 'Lỗi phân tích dữ liệu phản hồi', 'success': false};
    }
  }

  /// Lấy `message` từ body lỗi của server; trả về `null` nếu body không phải
  /// JSON có `message` (khi đó phía gọi tự dùng thông điệp mặc định).
  String? _extractErrorMessage(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = json.decode(body);
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_) {
      // Body không phải JSON — cắt bớt cho vừa một dòng log.
    }
    return AppLogger.preview(body, maxLength: 160);
  }
}
