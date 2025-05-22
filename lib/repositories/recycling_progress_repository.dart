import '../models/recycling_record_model.dart';
import '../models/waste_type_model.dart';
import '../core/network/network_info.dart';
import '../data/datasources/local_data_source.dart';
import '../data/datasources/remote_data_source.dart';
import '../models/recycling_statistics_model.dart';
import 'dart:developer' as developer;

class RecyclingProgressRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  RecyclingProgressRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  Future<List<RecyclingRecord>> getRecyclingRecords() async {
    try {
      // TODO: Implement real API call to get recycling records
      // For now, return an empty list until real data source is connected
      return [];
    } catch (e) {
      throw Exception('Failed to fetch recycling records: $e');
    }
  }

  Future<List<WasteType>> getWasteTypes() async {
    try {
      // TODO: Implement real API call to get waste types
      // For now, return an empty list until real data source is connected
      return [];
    } catch (e) {
      throw Exception('Failed to fetch waste types: $e');
    }
  }
  
  // Fetch recycling statistics from the API
  Future<RecyclingStatisticsData> getRecyclingStatistics({
    required String fromDate,
    required String toDate,
    String? wasteTypeId,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        throw Exception('Không có kết nối internet');
      }
      
      developer.log('Đang lấy thống kê tái chế từ API...');
      return await remoteDataSource.getRecyclingStatistics(
        fromDate: fromDate,
        toDate: toDate,
        wasteTypeId: wasteTypeId,
      );
    } catch (e) {
      developer.log('Lỗi khi lấy thống kê tái chế: $e');
      throw Exception('Không thể lấy thống kê tái chế: $e');
    }
  }

  // Filter records by date range
  List<RecyclingRecord> filterByDateRange(
    List<RecyclingRecord> records, 
    DateTime startDate, 
    DateTime endDate
  ) {
    return records.where((record) {
      return record.date.isAfter(startDate) && 
             record.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
  
  // Filter records by waste type
  List<RecyclingRecord> filterByWasteType(
    List<RecyclingRecord> records, 
    String wasteTypeId
  ) {
    return records.where((record) => record.wasteTypeId == wasteTypeId).toList();
  }
  
  // Calculate statistics
  Map<String, double> calculateWasteTypeQuantities(List<RecyclingRecord> records) {
    final Map<String, double> quantities = {};
    
    for (var record in records) {
      if (quantities.containsKey(record.wasteTypeName)) {
        quantities[record.wasteTypeName] = 
            quantities[record.wasteTypeName]! + record.weight;
      } else {
        quantities[record.wasteTypeName] = record.weight;
      }
    }
    
    return quantities;
  }
  
  double calculateTotalWeight(List<RecyclingRecord> records) {
    return records.fold(0, (total, record) => total + record.weight);
  }
} 