import 'package:wasteanmagement/core/api/api_client.dart';
import 'package:wasteanmagement/core/api/api_constants.dart';
import 'package:wasteanmagement/models/transaction.dart';

class TransactionRepository {
  final ApiClient apiClient;

  TransactionRepository({required this.apiClient});

  Future<TransactionResponse> getTransactions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null) {
      queryParams['status'] = status;
    }

    String url = ApiConstants.transactions;
    if (queryParams.isNotEmpty) {
      url += '?';
      url += queryParams.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('&');
    }

    try {
      print('Fetching transactions from: $url');
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
    String? proofImageUrl,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'collection_point_id': collectionPointId,
        'waste_type_id': wasteTypeId,
        'quantity': quantity,
        'unit': unit,
      };

      if (proofImageUrl != null) {
        data['proof_image_url'] = proofImageUrl;
      }

      print('Creating transaction with data: $data');
      final response = await apiClient.post(
        ApiConstants.transactions,
        body: data,
      );

      // Chuyển đổi từ ApiResponse sang dạng tương thích với TransactionResponse
      final bool isSuccess = response.isSuccess;
      final String message = response.message;

      return {
        'success': isSuccess,
        'message': message,
        'data': response.data['data']
      };
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
}