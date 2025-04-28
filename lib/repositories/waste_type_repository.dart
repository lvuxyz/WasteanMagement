import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/waste_type_model.dart';
import '../models/collection_point_model.dart';
import '../constants/api_constants.dart';
import '../core/api/api_client.dart';
import 'dart:developer' as developer;

class WasteTypeRepository {
  final ApiClient apiClient;
  final String baseUrl = ApiConstants.baseUrl;
  
  WasteTypeRepository({required this.apiClient});

  Future<List<WasteType>> getWasteTypes() async {
    try {
      developer.log('Đang gọi API ${ApiConstants.wasteTypes}');
      
      final response = await apiClient.get(ApiConstants.wasteTypes);
      
      developer.log('Phản hồi từ API: Mã trạng thái ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Dữ liệu phản hồi: $data');
        
        if (data['status'] == 'success') {
          final List<dynamic> wasteTypesJson = data['data']['wasteTypes'];
          return wasteTypesJson.map((json) => WasteType.fromJson(json)).toList();
        } else {
          developer.log('Lỗi API: ${data['message']}', error: data['message']);
          throw Exception('API error: ${data['message']}');
        }
      } else {
        developer.log('Lỗi khi tải loại rác. Mã trạng thái: ${response.statusCode}', 
          error: 'Lỗi HTTP ${response.statusCode}');
        throw Exception('Failed to load waste types. Status code: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Lỗi khi tải danh sách loại rác: $e', error: e);
      throw Exception('Failed to load waste types: $e');
    }
  }

  // Phương thức để thêm loại rác vào kế hoạch tái chế
  Future<bool> addToRecyclingPlan(int wasteTypeId) async {
    // TODO: Implement actual API integration
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // Phương thức tìm WasteType theo ID
  Future<WasteType> getWasteTypeById(int wasteTypeId) async {
    try {
      developer.log('Đang gọi API ${ApiConstants.wasteTypes}/$wasteTypeId');
      
      final response = await apiClient.get('${ApiConstants.wasteTypes}/$wasteTypeId');
      
      developer.log('Phản hồi từ API: Mã trạng thái ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Dữ liệu phản hồi: $data');
        
        if (data['status'] == 'success') {
          final Map<String, dynamic> wasteTypeJson = data['data']['wasteType'];
          return WasteType.fromJson(wasteTypeJson);
        } else {
          developer.log('Lỗi API: ${data['message']}', error: data['message']);
          throw Exception('API error: ${data['message']}');
        }
      } else {
        developer.log('Lỗi khi tải chi tiết loại rác. Mã trạng thái: ${response.statusCode}',
          error: 'Lỗi HTTP ${response.statusCode}');
        throw Exception('Failed to load waste type. Status code: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Lỗi khi tải chi tiết loại rác: $e', error: e);
      throw Exception('Failed to load waste type: $e');
    }
  }

  // Phương thức lấy danh sách điểm thu gom cho một loại rác
  Future<List<CollectionPoint>> getCollectionPointsForWasteType(int wasteTypeId) async {
    // TODO: Implement actual API integration
    // Giả lập độ trễ khi tải dữ liệu từ server
    await Future.delayed(const Duration(milliseconds: 500));

    // Dữ liệu mẫu - trong thực tế sẽ lấy từ API
    return [
      CollectionPoint(
        id: '1',
        name: 'Trung tâm Tái chế Hà Nội',
        address: '123 Đường Nguyễn Trãi, Thanh Xuân, Hà Nội',
        description: 'Trung tâm tái chế lớn nhất khu vực',
        latitude: 21.007,
        longitude: 105.823,
        imageUrl: 'assets/images/collection_point1.jpg',
        phone: '0987654321',
        email: 'contact@recycling.com',
        website: 'www.recycling.com',
        isActive: true,
        createdAt: '2023-01-01',
        updatedAt: '2023-06-01',
        status: 'active',
        current_load: 45.0,
        capacity: 100.0,
        operating_hours: '08:00 - 17:00, Thứ 2 - Thứ 7',
      ),
      CollectionPoint(
        id: '2',
        name: 'Điểm thu gom Cầu Giấy',
        address: '45 Đường Cầu Giấy, Cầu Giấy, Hà Nội',
        description: 'Điểm thu gom chuyên nhựa và giấy',
        latitude: 21.031,
        longitude: 105.801,
        imageUrl: 'assets/images/collection_point2.jpg',
        phone: '0123456789',
        email: 'caugiay@recycling.com',
        website: 'www.recycling.com/caugiay',
        isActive: true,
        createdAt: '2023-02-15',
        updatedAt: '2023-05-20',
        status: 'active',
        current_load: 30.0,
        capacity: 80.0,
        operating_hours: '07:30 - 16:30, Hàng ngày',
      ),
    ];
  }

  // Phương thức lấy tất cả các điểm thu gom
  Future<List<CollectionPoint>> getAllCollectionPoints() async {
    // TODO: Implement actual API integration
    // Giả lập độ trễ khi tải dữ liệu từ server
    await Future.delayed(const Duration(milliseconds: 500));

    // Dữ liệu mẫu - trong thực tế sẽ lấy từ API
    return [
      CollectionPoint(
        id: '1',
        name: 'Trung tâm Tái chế Hà Nội',
        address: '123 Đường Nguyễn Trãi, Thanh Xuân, Hà Nội',
        description: 'Trung tâm tái chế lớn nhất khu vực',
        latitude: 21.007,
        longitude: 105.823,
        imageUrl: 'assets/images/collection_point1.jpg',
        phone: '0987654321',
        email: 'contact@recycling.com',
        website: 'www.recycling.com',
        isActive: true,
        createdAt: '2023-01-01',
        updatedAt: '2023-06-01',
        status: 'active',
        current_load: 45.0,
        capacity: 100.0,
        operating_hours: '08:00 - 17:00, Thứ 2 - Thứ 7',
      ),
      CollectionPoint(
        id: '2',
        name: 'Điểm thu gom Cầu Giấy',
        address: '45 Đường Cầu Giấy, Cầu Giấy, Hà Nội',
        description: 'Điểm thu gom chuyên nhựa và giấy',
        latitude: 21.031,
        longitude: 105.801,
        imageUrl: 'assets/images/collection_point2.jpg',
        phone: '0123456789',
        email: 'caugiay@recycling.com',
        website: 'www.recycling.com/caugiay',
        isActive: true,
        createdAt: '2023-02-15',
        updatedAt: '2023-05-20',
        status: 'active',
        current_load: 30.0,
        capacity: 80.0,
        operating_hours: '07:30 - 16:30, Hàng ngày',
      ),
      CollectionPoint(
        id: '3',
        name: 'Điểm thu gom Thanh Xuân',
        address: '78 Đường Nguyễn Trãi, Thanh Xuân, Hà Nội',
        description: 'Điểm thu gom tất cả các loại rác tái chế',
        latitude: 21.001,
        longitude: 105.815,
        imageUrl: 'assets/images/collection_point3.jpg',
        phone: '0369852147',
        email: 'thanhxuan@recycling.com',
        website: 'www.recycling.com/thanhxuan',
        isActive: true,
        createdAt: '2023-03-10',
        updatedAt: '2023-05-15',
        status: 'active',
        current_load: 65.0,
        capacity: 120.0,
        operating_hours: '08:00 - 18:00, Thứ 2 - Thứ 6',
      ),
    ];
  }

  // Phương thức xóa loại rác
  Future<bool> deleteWasteType(int wasteTypeId) async {
    // Giả lập độ trễ khi xóa dữ liệu trên server
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trong thực tế, cần kiểm tra xem thao tác có thành công không
    return true;
  }

  // Phương thức liên kết loại rác với điểm thu gom
  Future<bool> linkCollectionPoint(int wasteTypeId, int collectionPointId) async {
    // Giả lập độ trễ khi thực hiện thao tác trên server
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trong thực tế, cần kiểm tra xem thao tác có thành công không
    return true;
  }

  // Phương thức hủy liên kết loại rác với điểm thu gom
  Future<bool> unlinkCollectionPoint(int wasteTypeId, int collectionPointId) async {
    // Giả lập độ trễ khi thực hiện thao tác trên server
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trong thực tế, cần kiểm tra xem thao tác có thành công không
    return true;
  }
  
  // Phương thức tạo loại rác mới
  Future<WasteType> createWasteType(WasteType wasteType) async {
    // Giả lập độ trễ khi tạo dữ liệu trên server
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Giả lập tạo ID mới
    final newWasteType = WasteType(
      id: DateTime.now().millisecondsSinceEpoch % 1000, // Tạo ID giả
      name: wasteType.name,
      category: wasteType.category,
      description: wasteType.description,
      icon: wasteType.icon,
      color: wasteType.color,
      handlingInstructions: wasteType.handlingInstructions,
      examples: wasteType.examples,
      unitPrice: wasteType.unitPrice,
      unit: wasteType.unit,
      recentPoints: wasteType.recentPoints,
      recyclable: wasteType.recyclable,
    );
    
    // Trong thực tế, sẽ lưu dữ liệu này xuống database hoặc gửi đến server
    return newWasteType;
  }
  
  // Phương thức cập nhật loại rác
  Future<WasteType> updateWasteType(WasteType wasteType) async {
    // Giả lập độ trễ khi cập nhật dữ liệu trên server
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trong thực tế, sẽ cập nhật xuống database hoặc gửi đến server
    return wasteType;
  }
}