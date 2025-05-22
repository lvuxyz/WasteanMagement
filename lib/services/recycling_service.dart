import 'dart:developer' as developer;
import 'package:wasteanmagement/models/recycling_report_model.dart';

import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/recycling_process_model.dart';
import '../utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class RecyclingService {
  final ApiClient _apiClient;
  
  RecyclingService({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient(
          client: http.Client(),
          secureStorage: SecureStorage(),
        );
  
  // Lấy danh sách quy trình tái chế có phân trang
  Future<Map<String, dynamic>> getRecyclingProcesses({
    int page = 1, 
    int limit = 10,
    String? status,
    String? wasteTypeId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final url = ApiConstants.recyclingAll;
      
      developer.log('Gọi API lấy danh sách quy trình tái chế: $url');
      final response = await _apiClient.get(url);
      
      if (response.isSuccess) {
        final data = response.body;
        final List<RecyclingProcess> processes = [];
        
        if (data['data'] != null && data['data'] is List) {
          for (var item in data['data']) {
            processes.add(RecyclingProcess.fromJson(item));
          }
        }
        
        return {
          'processes': processes,
          'total': processes.length,
          'page': 1,
          'limit': processes.length,
          'totalPages': 1,
        };
      } else {
        throw Exception('Lỗi khi lấy danh sách quy trình tái chế: ${response.message}');
      }
    } catch (e) {
      developer.log('Lỗi khi lấy danh sách quy trình tái chế: $e', error: e);
      throw Exception('Không thể lấy danh sách quy trình tái chế: $e');
    }
  }
  
  // Lấy toàn bộ danh sách quy trình tái chế (không phân trang)
  Future<List<RecyclingProcess>> getAllRecyclingProcesses() async {
    try {
      final url = ApiConstants.recyclingAll;
      developer.log('Gọi API lấy toàn bộ quy trình tái chế: $url');
      final response = await _apiClient.get(url);
      
      if (response.isSuccess) {
        final data = response.body;
        final List<RecyclingProcess> processes = [];
        
        if (data['data'] != null && data['data'] is List) {
          for (var item in data['data']) {
            processes.add(RecyclingProcess.fromJson(item));
          }
        }
        
        return processes;
      } else {
        throw Exception('Lỗi khi lấy toàn bộ quy trình tái chế: ${response.message}');
      }
    } catch (e) {
      developer.log('Lỗi khi lấy toàn bộ quy trình tái chế: $e', error: e);
      throw Exception('Không thể lấy toàn bộ quy trình tái chế: $e');
    }
  }
  
  // Lấy chi tiết quy trình tái chế
  Future<RecyclingProcess> getRecyclingProcessDetail(String id) async {
    try {
      final url = ApiConstants.recyclingDetail(id);
      developer.log('Gọi API lấy chi tiết quy trình tái chế: $url');
      final response = await _apiClient.get(url);
      
      if (response.isSuccess) {
        final data = response.body;
        
        if (data['data'] != null) {
          return RecyclingProcess.fromJson(data['data']);
        } else {
          throw Exception('Không tìm thấy dữ liệu quy trình tái chế');
        }
      } else {
        throw Exception('Lỗi khi lấy chi tiết quy trình tái chế: ${response.message}');
      }
    } catch (e) {
      developer.log('Lỗi khi lấy chi tiết quy trình tái chế: $e', error: e);
      throw Exception('Không thể lấy chi tiết quy trình tái chế: $e');
    }
  }
  
  // Tạo mới quy trình tái chế (chỉ ADMIN)
  Future<RecyclingProcess> createRecyclingProcess({
    required String transactionId,
    required String wasteTypeId,
    double? quantity,
    String? notes,
  }) async {
    try {
      final url = ApiConstants.recycling;
      developer.log('Gọi API tạo mới quy trình tái chế: $url');
      
      final body = {
        'transaction_id': transactionId,
        'waste_type_id': wasteTypeId,
        if (quantity != null) 'quantity': quantity,
        if (notes != null) 'notes': notes,
      };
      
      final response = await _apiClient.post(url, body: body);
      
      if (response.isSuccess) {
        final data = response.body;
        
        if (data['data'] != null) {
          return RecyclingProcess.fromJson(data['data']);
        } else {
          throw Exception('Không nhận được dữ liệu quy trình tái chế sau khi tạo');
        }
      } else {
        throw Exception('Lỗi khi tạo quy trình tái chế: ${response.message}');
      }
    } catch (e) {
      developer.log('Lỗi khi tạo quy trình tái chế: $e', error: e);
      throw Exception('Không thể tạo quy trình tái chế: $e');
    }
  }
  
  // Cập nhật quy trình tái chế (chỉ ADMIN)
  Future<RecyclingProcess> updateRecyclingProcess({
    required String id,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final url = ApiConstants.recyclingDetail(id);
      developer.log('Gọi API cập nhật quy trình tái chế: $url');
      developer.log('Dữ liệu cập nhật: $updateData');
      
      final response = await _apiClient.put(url, body: updateData);
      
      if (response.isSuccess) {
        final data = response.body;
        
        if (data['data'] != null) {
          return RecyclingProcess.fromJson(data['data']);
        } else {
          throw Exception('Không nhận được dữ liệu quy trình tái chế sau khi cập nhật');
        }
      } else {
        throw Exception('Lỗi khi cập nhật quy trình tái chế: ${response.message}');
      }
    } catch (e) {
      developer.log('Lỗi khi cập nhật quy trình tái chế: $e', error: e);
      throw Exception('Không thể cập nhật quy trình tái chế: $e');
    }
  }
  
  // Lấy báo cáo thống kê quy trình tái chế (chỉ ADMIN)
  Future<RecyclingReport> getRecyclingReport({
    String? fromDate,
    String? toDate,
    String? wasteTypeId,
  }) async {
    try {
      String url = ApiConstants.recyclingReport;
      
      if (fromDate != null || toDate != null || wasteTypeId != null) {
        url += '?';
        if (fromDate != null) url += 'from=$fromDate&';
        if (toDate != null) url += 'to=$toDate&';
        if (wasteTypeId != null) url += 'waste_type_id=$wasteTypeId&';
        url = url.substring(0, url.length - 1); // Loại bỏ dấu & cuối cùng
      }
      
      developer.log('Gọi API lấy báo cáo thống kê tái chế: $url');
      final response = await _apiClient.get(url);
      
      if (response.isSuccess) {
        final data = response.body;
        
        if (data['data'] != null) {
          return RecyclingReport.fromJson(data['data']);
        } else {
          throw Exception('Không tìm thấy dữ liệu báo cáo tái chế');
        }
      } else {
        throw Exception('Lỗi khi lấy báo cáo thống kê tái chế: ${response.message}');
      }
    } catch (e) {
      developer.log('Lỗi khi lấy báo cáo thống kê tái chế: $e', error: e);
      throw Exception('Không thể lấy báo cáo thống kê tái chế: $e');
    }
  }
  
  // Lấy thống kê số liệu tái chế (chỉ ADMIN)
  Future<Map<String, dynamic>> getRecyclingStatistics({
    String? fromDate,
    String? toDate,
    String? wasteTypeId,
  }) async {
    try {
      String url = ApiConstants.recyclingStatistics;
      
      if (fromDate != null || toDate != null || wasteTypeId != null) {
        url += '?';
        if (fromDate != null) url += 'from=$fromDate&';
        if (toDate != null) url += 'to=$toDate&';
        if (wasteTypeId != null) url += 'waste_type_id=$wasteTypeId&';
        url = url.substring(0, url.length - 1); // Loại bỏ dấu & cuối cùng
      }
      
      developer.log('Gọi API lấy thống kê số liệu tái chế: $url');
      final response = await _apiClient.get(url);
      
      if (response.isSuccess) {
        final data = response.body;
        
        if (data['data'] != null) {
          return data['data'];
        } else {
          throw Exception('Không tìm thấy dữ liệu thống kê tái chế');
        }
      } else {
        throw Exception('Lỗi khi lấy thống kê số liệu tái chế: ${response.message}');
      }
    } catch (e) {
      developer.log('Lỗi khi lấy thống kê số liệu tái chế: $e', error: e);
      throw Exception('Không thể lấy thống kê số liệu tái chế: $e');
    }
  }
  
  // Lấy danh sách quy trình tái chế theo người dùng
  Future<List<RecyclingProcess>> getUserRecyclingProcesses(String userId) async {
    try {
      final url = '${ApiConstants.recycling}/user/$userId';
      developer.log('Gọi API lấy quy trình tái chế của người dùng: $url');
      final response = await _apiClient.get(url);
      
      if (response.isSuccess) {
        final data = response.body;
        final List<RecyclingProcess> processes = [];
        
        if (data['data'] != null && data['data'] is List) {
          for (var item in data['data']) {
            processes.add(RecyclingProcess.fromJson(item));
          }
        }
        
        return processes;
      } else {
        throw Exception('Lỗi khi lấy quy trình tái chế của người dùng: ${response.message}');
      }
    } catch (e) {
      developer.log('Lỗi khi lấy quy trình tái chế của người dùng: $e', error: e);
      throw Exception('Không thể lấy quy trình tái chế của người dùng: $e');
    }
  }
  
  // Gửi thông báo cập nhật quy trình tái chế (chỉ ADMIN)
  Future<bool> sendRecyclingNotification(String id, String message) async {
    try {
      final url = '${ApiConstants.recycling}/notify/$id';
      developer.log('Gọi API gửi thông báo cập nhật quy trình tái chế: $url');
      
      final response = await _apiClient.post(url, body: {
        'message': message,
      });
      
      if (response.isSuccess) {
        return true;
      } else {
        throw Exception('Lỗi khi gửi thông báo cập nhật quy trình tái chế: ${response.message}');
      }
    } catch (e) {
      developer.log('Lỗi khi gửi thông báo cập nhật quy trình tái chế: $e', error: e);
      throw Exception('Không thể gửi thông báo cập nhật quy trình tái chế: $e');
    }
  }
} 