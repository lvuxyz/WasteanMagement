import 'dart:convert';
import '../core/api/api_client.dart';

class TransactionService {
  final ApiClient apiClient;

  TransactionService({required this.apiClient});

  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int limit = 10,
    String? status,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      var queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;

      final response = await apiClient.get('/transactions', headers: {'query': json.encode(queryParams)});
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'transactions': data['data']['items'] ?? [],
          'total': data['data']['total'] ?? 0,
          'page': data['data']['page'] ?? 1,
          'limit': data['data']['limit'] ?? 10,
          'totalPages': data['data']['total_pages'] ?? 1,
        };
      } else {
        throw Exception(data['message'] ?? 'Failed to load transactions');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  Future<List<dynamic>> getAllTransactions() async {
    try {
      final response = await apiClient.get('/transactions/all');
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return data['data'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Failed to load all transactions');
      }
    } catch (e) {
      throw Exception('Error fetching all transactions: $e');
    }
  }

  Future<dynamic> getTransactionById(String id) async {
    try {
      final response = await apiClient.get('/transactions/$id');
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to load transaction');
      }
    } catch (e) {
      throw Exception('Error fetching transaction: $e');
    }
  }

  Future<dynamic> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      final response = await apiClient.post(
        '/transactions', 
        body: transactionData,
      );
      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to create transaction');
      }
    } catch (e) {
      throw Exception('Error creating transaction: $e');
    }
  }

  Future<dynamic> updateTransaction(String id, Map<String, dynamic> transactionData) async {
    try {
      final response = await apiClient.put(
        '/transactions/$id', 
        body: transactionData,
      );
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to update transaction');
      }
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      final response = await apiClient.delete('/transactions/$id');
      
      if (response.statusCode == 204) {
        return true;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete transaction');
      }
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }
} 