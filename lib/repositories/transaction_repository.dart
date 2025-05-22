import 'package:wasteanmagement/core/api/api_client.dart';
import 'package:wasteanmagement/core/api/api_constants.dart';
import 'package:wasteanmagement/models/transaction.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;

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

    // Sử dụng URL chính xác cho admin
    final String adminUrl = 'http://103.27.239.248:3000/api/v1/transactions';
    String url = isAdmin 
        ? adminUrl // Admin API endpoint chính xác
        : ApiConstants.transactions; // Regular API endpoint
    
    if (queryParams.isNotEmpty) {
      url += '?';
      url += queryParams.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('&');
    }

    try {
      print('Fetching transactions with isAdmin=$isAdmin from URL: $url');
      final response = await apiClient.get(url);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Transactions API response: ${response.data}');
        return TransactionResponse.fromJson(response.data);
      } else {
        print('API error: Status ${response.statusCode}, ${response.data['message']}');
        throw Exception('Failed to load transactions: ${response.data['message']}');
      }
    } catch (e) {
      print('Exception in getTransactions: $e');
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
      print('Fetching my transactions from: $url');
      final response = await apiClient.get(url);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('My transactions API response: ${response.data}');
        return TransactionResponse.fromJson(response.data);
      } else {
        print('API error: Status ${response.statusCode}, ${response.data['message']}');
        throw Exception('Failed to load my transactions: ${response.data['message']}');
      }
    } catch (e) {
      print('Exception in getMyTransactions: $e');
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

        print('Creating transaction with data: $data');
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

        print('Sending multipart request with image to: ${ApiConstants.transactions}');
        
        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('Transaction API response: ${response.statusCode}, ${response.body}');

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
      print('Exception in createTransaction: $e');
      throw Exception('Failed to create transaction: $e');
    }
  }
  
  Future<Map<String, dynamic>> updateTransactionStatus({
    required int transactionId,
    required String status,
  }) async {
    try {
      final String url = '${ApiConstants.transactions}/$transactionId/status';
      print('Updating transaction status: $url with status: $status');
      
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
      print('Exception in updateTransactionStatus: $e');
      throw Exception('Failed to update transaction status: $e');
    }
  }
  
  Future<Map<String, dynamic>> deleteTransaction(int transactionId) async {
    try {
      final String url = '${ApiConstants.transactions}/$transactionId';
      print('Deleting transaction: $url');
      
      final response = await apiClient.delete(url);
      
      // Convert response to expected format
      final bool isSuccess = response.isSuccess;
      final String message = response.message;
      
      return {
        'success': isSuccess,
        'message': message,
      };
    } catch (e) {
      print('Exception in deleteTransaction: $e');
      throw Exception('Failed to delete transaction: $e');
    }
  }
  
  Future<Map<String, dynamic>> getTransactionById(int transactionId) async {
    try {
      final String url = '${ApiConstants.transactions}/$transactionId';
      print('Fetching transaction details: $url');
      
      final response = await apiClient.get(url);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Transaction details response: ${response.data}');
        return {
          'success': true,
          'data': response.data['data'],
        };
      } else {
        print('API error: Status ${response.statusCode}, ${response.data['message']}');
        throw Exception('Failed to load transaction details: ${response.data['message']}');
      }
    } catch (e) {
      print('Exception in getTransactionById: $e');
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
      print('Updating transaction: $url');
      
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

        print('Sending multipart PUT request with image to: $url');
        
        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('Transaction update API response: ${response.statusCode}, ${response.body}');

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
      print('Exception in updateTransaction: $e');
      throw Exception('Failed to update transaction: $e');
    }
  }
  
  Future<Map<String, dynamic>> getTransactionHistory(int transactionId) async {
    try {
      final String url = '${ApiConstants.transactions}/$transactionId/history';
      print('Fetching transaction history: $url');
      
      final response = await apiClient.get(url);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Transaction history response: ${response.data}');
        return {
          'success': true,
          'data': response.data['data'],
        };
      } else {
        print('API error: Status ${response.statusCode}, ${response.data['message']}');
        throw Exception('Failed to load transaction history: ${response.data['message']}');
      }
    } catch (e) {
      print('Exception in getTransactionHistory: $e');
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