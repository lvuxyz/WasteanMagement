import 'package:wasteanmagement/core/api/api_client.dart';
import 'package:wasteanmagement/core/api/api_constants.dart';
import 'package:wasteanmagement/models/transaction.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../utils/app_logger.dart';

class TransactionRepository {
  final ApiClient apiClient;

  TransactionRepository({required this.apiClient});

  Future<TransactionResponse> getTransactions({
    int page = 1,
    int limit = 10,
    String? status,
    bool isAdmin = false,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null) {
      queryParams['status'] = status;
    }

    // Admin và người dùng thường cùng dùng một endpoint; trước đây admin bị
    // gắn cứng địa chỉ máy chủ nên không đổi theo API_BASE_URL được.
    String url = ApiConstants.transactions;

    if (queryParams.isNotEmpty) {
      url += '?';
      url += queryParams.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('&');
    }

    try {
      AppLogger.d('Transaction', 'Lấy danh sách giao dịch · isAdmin=$isAdmin');
      final response = await apiClient.get(url);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = TransactionResponse.fromJson(response.data);
        AppLogger.d('Transaction',
            'Nhận ${result.data.length} giao dịch (trang ${result.pagination.page}/${result.pagination.pages}, tổng ${result.pagination.total})');
        return result;
      } else {
        throw Exception('Failed to load transactions: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  Future<TransactionResponse> getMyTransactions({
    int page = 1,
    int limit = 10,
    String? status,
    int? collectionPointId,
    int? wasteTypeId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null) {
      queryParams['status'] = status;
    }
    if (collectionPointId != null) {
      queryParams['collection_point_id'] = collectionPointId.toString();
    }
    if (wasteTypeId != null) {
      queryParams['waste_type_id'] = wasteTypeId.toString();
    }
    if (dateFrom != null) {
      queryParams['date_from'] = dateFrom;
    }
    if (dateTo != null) {
      queryParams['date_to'] = dateTo;
    }

    String url = '${ApiConstants.transactions}/my-transactions';
    if (queryParams.isNotEmpty) {
      url += '?';
      url += queryParams.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('&');
    }

    try {
      final response = await apiClient.get(url);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = TransactionResponse.fromJson(response.data);
        AppLogger.d('Transaction',
            'Nhận ${result.data.length} giao dịch của tôi (trang ${result.pagination.page}/${result.pagination.pages})');
        return result;
      } else {
        throw Exception('Failed to load my transactions: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to load my transactions: $e');
    }
  }

  Future<Map<String, dynamic>> createTransaction({
    required int collectionPointId,
    required int wasteTypeId,
    required double quantity,
    required String unit,
    File? proofImage,
  }) async {
    try {
      // If there's no image, use the standard API client
      if (proofImage == null) {
        final Map<String, dynamic> data = {
          'collection_point_id': collectionPointId,
          'waste_type_id': wasteTypeId,
          'quantity': quantity,
          'unit': unit,
        };

        AppLogger.d('Transaction', 'Tạo giao dịch · ${AppLogger.preview(data)}');
        final response = await apiClient.post(
          ApiConstants.transactions,
          body: data,
        );

        // Convert response to expected format
        final bool isSuccess = response.isSuccess;
        final String message = response.message;

        return {
          'success': isSuccess,
          'message': message,
          'data': response.data['data']
        };
      }
      // If there's an image, use multipart request
      else {
        // Get token
        final token = await apiClient.secureStorage.getToken();
        if (token == null) {
          throw Exception('Không tìm thấy token xác thực');
        }

        // Create multipart request
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConstants.transactions),
        );

        // Add authorization header
        request.headers.addAll({
          'Authorization': 'Bearer $token',
        });

        // Add transaction data fields
        request.fields['collection_point_id'] = collectionPointId.toString();
        request.fields['waste_type_id'] = wasteTypeId.toString();
        request.fields['quantity'] = quantity.toString();
        request.fields['unit'] = unit;

        // Add image file
        final fileExtension = path.extension(proofImage.path).replaceAll('.', '');
        final contentType = _getMimeType(fileExtension);

        request.files.add(await http.MultipartFile.fromPath(
          'proof_image', // This MUST be 'proof_image', not 'proof_image_url'
          proofImage.path,
          contentType: MediaType.parse(contentType),
        ));

        AppLogger.d('Transaction',
            '→ POST ${AppLogger.shortUrl(ApiConstants.transactions)} (multipart, kèm ảnh)');

        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        AppLogger.d('Transaction',
            '← ${response.statusCode} POST ${AppLogger.shortUrl(ApiConstants.transactions)} (multipart)');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final responseData = json.decode(response.body);
          return {
            'success': true,
            'message': responseData['message'] ?? 'Tạo giao dịch thành công',
            'data': responseData['data']
          };
        } else {
          try {
            final errorData = json.decode(response.body);
            return {
              'success': false,
              'message': errorData['message'] ?? 'Lỗi khi tạo giao dịch',
            };
          } catch (e) {
            return {
              'success': false,
              'message': 'Lỗi khi tạo giao dịch: ${response.statusCode}',
            };
          }
        }
      }
    } catch (e) {
      AppLogger.e('Transaction', 'Tạo giao dịch thất bại', error: e);
      throw Exception('Failed to create transaction: $e');
    }
  }

  Future<Map<String, dynamic>> updateTransactionStatus({
    required int transactionId,
    required String status,
  }) async {
    try {
      final String url = '${ApiConstants.transactions}/$transactionId/status';
      AppLogger.d('Transaction', 'Đổi trạng thái giao dịch $transactionId sang $status');

      final Map<String, dynamic> data = {
        'status': status,
      };

      final response = await apiClient.patch(url, body: data);

      // Convert response to expected format
      final bool isSuccess = response.isSuccess;
      final String message = response.message;

      return {
        'success': isSuccess,
        'message': message,
        'data': response.data['data']
      };
    } catch (e) {
      AppLogger.e('Transaction', 'Đổi trạng thái giao dịch thất bại', error: e);
      throw Exception('Failed to update transaction status: $e');
    }
  }

  Future<Map<String, dynamic>> deleteTransaction(int transactionId) async {
    try {
      final String url = '${ApiConstants.transactions}/$transactionId';

      final response = await apiClient.delete(url);

      // Convert response to expected format
      final bool isSuccess = response.isSuccess;
      final String message = response.message;

      return {
        'success': isSuccess,
        'message': message,
      };
    } catch (e) {
      AppLogger.e('Transaction', 'Xóa giao dịch thất bại', error: e);
      throw Exception('Failed to delete transaction: $e');
    }
  }

  Future<Map<String, dynamic>> getTransactionById(int transactionId) async {
    try {
      final String url = '${ApiConstants.transactions}/$transactionId';

      final response = await apiClient.get(url);

      if (response.statusCode >= 200 && response.statusCode < 300) {
return {
          'success': true,
          'data': response.data['data'],
        };
      } else {
throw Exception('Failed to load transaction details: ${response.data['message']}');
      }
    } catch (e) {
      AppLogger.e('Transaction', 'Không lấy được chi tiết giao dịch', error: e);
      throw Exception('Failed to load transaction details: $e');
    }
  }

  Future<Map<String, dynamic>> updateTransaction({
    required int transactionId,
    required int collectionPointId,
    required int wasteTypeId,
    required double quantity,
    required String unit,
    File? proofImage,
  }) async {
    try {
      final String url = '${ApiConstants.transactions}/$transactionId';

      // If there's no image, use the standard API client
      if (proofImage == null) {
        final Map<String, dynamic> data = {
          'collection_point_id': collectionPointId,
          'waste_type_id': wasteTypeId,
          'quantity': quantity,
          'unit': unit,
        };

        final response = await apiClient.put(url, body: data);

        // Convert response to expected format
        final bool isSuccess = response.isSuccess;
        final String message = response.message;

        return {
          'success': isSuccess,
          'message': message,
          'data': response.data['data']
        };
      }
      // If there's an image, use multipart request
      else {
        // Get token
        final token = await apiClient.secureStorage.getToken();
        if (token == null) {
          throw Exception('Không tìm thấy token xác thực');
        }

        // Create multipart request
        final request = http.MultipartRequest(
          'PUT',
          Uri.parse(url),
        );

        // Add authorization header
        request.headers.addAll({
          'Authorization': 'Bearer $token',
        });

        // Add transaction data fields
        request.fields['collection_point_id'] = collectionPointId.toString();
        request.fields['waste_type_id'] = wasteTypeId.toString();
        request.fields['quantity'] = quantity.toString();
        request.fields['unit'] = unit;

        // Add image file
        final fileExtension = path.extension(proofImage.path).replaceAll('.', '');
        final contentType = _getMimeType(fileExtension);

        request.files.add(await http.MultipartFile.fromPath(
          'proof_image', // This MUST be 'proof_image', not 'proof_image_url'
          proofImage.path,
          contentType: MediaType.parse(contentType),
        ));

        AppLogger.d('Transaction',
            '→ PUT ${AppLogger.shortUrl(url)} (multipart, kèm ảnh)');

        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        AppLogger.d('Transaction',
            '← ${response.statusCode} PUT ${AppLogger.shortUrl(url)} (multipart)');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final responseData = json.decode(response.body);
          return {
            'success': true,
            'message': responseData['message'] ?? 'Cập nhật giao dịch thành công',
            'data': responseData['data']
          };
        } else {
          try {
            final errorData = json.decode(response.body);
            return {
              'success': false,
              'message': errorData['message'] ?? 'Lỗi khi cập nhật giao dịch',
            };
          } catch (e) {
            return {
              'success': false,
              'message': 'Lỗi khi cập nhật giao dịch: ${response.statusCode}',
            };
          }
        }
      }
    } catch (e) {
      AppLogger.e('Transaction', 'Cập nhật giao dịch thất bại', error: e);
      throw Exception('Failed to update transaction: $e');
    }
  }

  Future<Map<String, dynamic>> getTransactionHistory(int transactionId) async {
    try {
      final String url = '${ApiConstants.transactions}/$transactionId/history';

      final response = await apiClient.get(url);

      if (response.statusCode >= 200 && response.statusCode < 300) {
return {
          'success': true,
          'data': response.data['data'],
        };
      } else {
throw Exception('Failed to load transaction history: ${response.data['message']}');
      }
    } catch (e) {
      AppLogger.e('Transaction', 'Không lấy được lịch sử giao dịch', error: e);
      throw Exception('Failed to load transaction history: $e');
    }
  }

  // Helper method to get mime type from file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}