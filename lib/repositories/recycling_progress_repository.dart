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

  // Trong môi trường thực, phương thức này sẽ gọi API
  // Nhưng ở đây, chúng ta sẽ trả về dữ liệu mẫu
  Future<List<RecyclingRecord>> getRecyclingRecords() async {
    // Mock data
    return [
      RecyclingRecord(
        id: '1',
        wasteTypeId: '1',
        wasteTypeName: 'Giấy',
        wasteTypeCategory: 'Giấy và Carton',
        weight: 2.5,
        collectionPointId: '1',
        collectionPointName: 'Trung tâm Tái chế Hà Nội',
        date: DateTime.now().subtract(const Duration(days: 2)),
        userId: 'user1',
        isVerified: true,
        rewardPoints: 25,
      ),
      RecyclingRecord(
        id: '2',
        wasteTypeId: '2',
        wasteTypeName: 'Chai nhựa PET',
        wasteTypeCategory: 'Nhựa',
        weight: 1.2,
        collectionPointId: '2',
        collectionPointName: 'Điểm thu gom Cầu Giấy',
        date: DateTime.now().subtract(const Duration(days: 5)),
        userId: 'user1',
        isVerified: true,
        rewardPoints: 15,
      ),
      RecyclingRecord(
        id: '3',
        wasteTypeId: '3',
        wasteTypeName: 'Lon nhôm',
        wasteTypeCategory: 'Kim loại',
        weight: 0.8,
        collectionPointId: '1',
        collectionPointName: 'Trung tâm Tái chế Hà Nội',
        date: DateTime.now().subtract(const Duration(days: 10)),
        userId: 'user1',
        isVerified: true,
        rewardPoints: 12,
      ),
      RecyclingRecord(
        id: '4',
        wasteTypeId: '4',
        wasteTypeName: 'Thủy tinh',
        wasteTypeCategory: 'Thủy tinh',
        weight: 3.0,
        collectionPointId: '3',
        collectionPointName: 'Điểm thu gom Thanh Xuân',
        date: DateTime.now().subtract(const Duration(days: 15)),
        userId: 'user1',
        isVerified: true,
        rewardPoints: 30,
      ),
      RecyclingRecord(
        id: '5',
        wasteTypeId: '1',
        wasteTypeName: 'Giấy',
        wasteTypeCategory: 'Giấy và Carton',
        weight: 1.7,
        collectionPointId: '2',
        collectionPointName: 'Điểm thu gom Cầu Giấy',
        date: DateTime.now().subtract(const Duration(days: 20)),
        userId: 'user1',
        isVerified: true,
        rewardPoints: 17,
      ),
    ];
  }

  Future<List<WasteType>> getWasteTypes() async {
    // This would normally call an API or database
    // For now, return a simple mock list
    return [
      WasteType(
        id: 1,
        name: 'Giấy',
        description: 'Giấy các loại, bao gồm giấy báo, tạp chí, sách, hộp giấy',
        category: 'Giấy và Carton',
        icon: Icons.description,
        color: Colors.blue,
        recyclingMethod: 'Làm phẳng, buộc gọn gàng',
        examples: ['Giấy báo', 'Tạp chí', 'Hộp giấy', 'Sách'],
        buyingPrice: 5000,
        unit: 'kg',
        recentPoints: '25',
      ),
      WasteType(
        id: 2,
        name: 'Chai nhựa PET',
        description: 'Chai nhựa trong suốt dùng đựng nước, nước ngọt',
        category: 'Nhựa',
        icon: Icons.local_drink,
        color: Colors.green,
        recyclingMethod: 'Rửa sạch, bỏ nắp, làm bẹp',
        examples: ['Chai nước suối', 'Chai nước ngọt', 'Chai dầu gội'],
        buyingPrice: 10000,
        unit: 'kg',
        recentPoints: '15',
      ),
      WasteType(
        id: 3,
        name: 'Lon nhôm',
        description: 'Lon kim loại đựng đồ uống',
        category: 'Kim loại',
        icon: Icons.shopping_basket,
        color: Colors.grey,
        recyclingMethod: 'Rửa sạch, làm bẹp',
        examples: ['Lon bia', 'Lon nước ngọt', 'Lon nước tăng lực'],
        buyingPrice: 20000,
        unit: 'kg',
        recentPoints: '12',
      ),
      WasteType(
        id: 4,
        name: 'Thủy tinh',
        description: 'Chai, lọ thủy tinh các loại',
        category: 'Thủy tinh',
        icon: Icons.wine_bar,
        color: Colors.amber,
        recyclingMethod: 'Rửa sạch, tháo nhãn và nắp',
        examples: ['Chai nước hoa', 'Lọ đựng gia vị', 'Chai rượu'],
        buyingPrice: 8000,
        unit: 'kg',
        recentPoints: '30',
      ),
    ];
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