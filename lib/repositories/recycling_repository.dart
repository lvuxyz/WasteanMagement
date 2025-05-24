import 'dart:developer' as developer;
import 'package:wasteanmagement/models/recycling_report_model.dart';

import '../core/network/network_info.dart';
import '../models/recycling_process_model.dart';
import '../services/recycling_service.dart';

class RecyclingRepository {
  final RecyclingService _recyclingService;
  final NetworkInfo _networkInfo;

  RecyclingRepository({
    required RecyclingService recyclingService,
    required NetworkInfo networkInfo,
  }) : _recyclingService = recyclingService,
       _networkInfo = networkInfo;

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
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw Exception('Không có kết nối internet');
      }

      return await _recyclingService.getRecyclingProcesses(
        page: page,
        limit: limit,
        status: status,
        wasteTypeId: wasteTypeId,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      developer.log('Lỗi khi lấy danh sách quy trình tái chế: $e', error: e);
      throw Exception('Không thể lấy danh sách quy trình tái chế: $e');
    }
  }

  // Lấy toàn bộ danh sách quy trình tái chế (không phân trang)
  Future<List<RecyclingProcess>> getAllRecyclingProcesses() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw Exception('Không có kết nối internet');
      }

      return await _recyclingService.getAllRecyclingProcesses();
    } catch (e) {
      developer.log('Lỗi khi lấy toàn bộ quy trình tái chế: $e', error: e);
      throw Exception('Không thể lấy toàn bộ quy trình tái chế: $e');
    }
  }

  // Lấy chi tiết quy trình tái chế
  Future<RecyclingProcess> getRecyclingProcessDetail(String id) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw Exception('Không có kết nối internet');
      }

      return await _recyclingService.getRecyclingProcessDetail(id);
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
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw Exception('Không có kết nối internet');
      }

      return await _recyclingService.createRecyclingProcess(
        transactionId: transactionId,
        wasteTypeId: wasteTypeId,
        quantity: quantity,
        notes: notes,
      );
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
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw Exception('Không có kết nối internet');
      }

      return await _recyclingService.updateRecyclingProcess(
        id: id,
        updateData: updateData,
      );
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
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw Exception('Không có kết nối internet');
      }

      return await _recyclingService.getRecyclingReport(
        fromDate: fromDate,
        toDate: toDate,
        wasteTypeId: wasteTypeId,
      );
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
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw Exception('Không có kết nối internet');
      }

      return await _recyclingService.getRecyclingStatistics(
        fromDate: fromDate,
        toDate: toDate,
        wasteTypeId: wasteTypeId,
      );
    } catch (e) {
      developer.log('Lỗi khi lấy thống kê số liệu tái chế: $e', error: e);
      throw Exception('Không thể lấy thống kê số liệu tái chế: $e');
    }
  }

  // Lấy danh sách quy trình tái chế theo người dùng
  Future<List<RecyclingProcess>> getUserRecyclingProcesses(String userId) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw Exception('Không có kết nối internet');
      }

      return await _recyclingService.getUserRecyclingProcesses(userId);
    } catch (e) {
      developer.log('Lỗi khi lấy quy trình tái chế của người dùng: $e', error: e);
      throw Exception('Không thể lấy quy trình tái chế của người dùng: $e');
    }
  }

  // Gửi thông báo cập nhật quy trình tái chế (chỉ ADMIN)
  Future<bool> sendRecyclingNotification(String id, String message) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw Exception('Không có kết nối internet');
      }

      return await _recyclingService.sendRecyclingNotification(id, message);
    } catch (e) {
      developer.log('Lỗi khi gửi thông báo cập nhật quy trình tái chế: $e', error: e);
      throw Exception('Không thể gửi thông báo cập nhật quy trình tái chế: $e');
    }
  }
} 