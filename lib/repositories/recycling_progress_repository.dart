import '../models/recycling_record_model.dart';
import '../models/waste_type_model.dart';
import '../core/network/network_info.dart';
import '../data/datasources/local_data_source.dart';
import '../data/datasources/remote_data_source.dart';
import 'package:flutter/material.dart';

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
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        final records = await remoteDataSource.getRecyclingRecords();
        // Cache the records locally
        await localDataSource.cacheRecyclingRecords(records);
        return records;
      } else {
        // If offline, get cached records
        return await localDataSource.getLastRecyclingRecords();
      }
    } catch (e) {
      throw Exception('Failed to fetch recycling records: $e');
    }
  }

  Future<List<WasteType>> getWasteTypes() async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        final wasteTypes = await remoteDataSource.getWasteTypes();
        // Cache the waste types locally
        await localDataSource.cacheWasteTypes(wasteTypes);
        return wasteTypes;
      } else {
        // If offline, get cached waste types
        return await localDataSource.getLastWasteTypes();
      }
    } catch (e) {
      throw Exception('Failed to fetch waste types: $e');
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