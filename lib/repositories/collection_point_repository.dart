import 'dart:developer' as developer;
import '../core/api/api_constants.dart';
import '../core/api/api_client.dart';
import '../models/collection_point.dart';

class CollectionPointRepository {
  final ApiClient apiClient;
  
  CollectionPointRepository({required this.apiClient});

  // Lấy tất cả điểm thu gom
  Future<List<CollectionPoint>> getAllCollectionPoints() async {
    try {
      // This endpoint doesn't require authentication
      final response = await apiClient.get(ApiConstants.collectionPoints);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final collectionPointsResponse = CollectionPointsResponse.fromJson(response.data);
        return collectionPointsResponse.collectionPoints;
      } else {
        throw Exception('Failed to load collection points: ${response.data['message']}');
      }
    } catch (e) {
      print('Error fetching collection points: $e');
      throw Exception('Failed to load collection points: $e');
    }
  }

  // Lấy chi tiết điểm thu gom
  Future<CollectionPoint?> getCollectionPointById(int id) async {
    try {
      developer.log('Đang gọi API lấy chi tiết điểm thu gom: ${ApiConstants.collectionPoints}/$id');
      
      final response = await apiClient.get('${ApiConstants.collectionPoints}/$id');
      
      developer.log('Phản hồi từ API: Mã trạng thái ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Dữ liệu phản hồi: $data');
        
        if (data['status'] == 'success' && data['data'] != null && data['data']['collectionPoint'] != null) {
          final Map<String, dynamic> collectionPointJson = data['data']['collectionPoint'];
          return CollectionPoint.fromJson(collectionPointJson);
        } else {
          developer.log('Không tìm thấy chi tiết điểm thu gom trong phản hồi API');
          return null;
        }
      } else {
        developer.log('Lỗi khi tải chi tiết điểm thu gom. Mã trạng thái: ${response.statusCode}', 
          error: 'Lỗi HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      developer.log('Lỗi khi tải chi tiết điểm thu gom: $e', error: e);
      return null;
    }
  }
  
  // Tạo điểm thu gom mới
  Future<CollectionPoint?> createCollectionPoint({
    required String name,
    required String address, 
    required double latitude,
    required double longitude,
    required String operatingHours,
    required int capacity,
    String status = 'active',
  }) async {
    try {
      developer.log('Đang gọi API tạo điểm thu gom mới: ${ApiConstants.collectionPoints}');
      
      final body = {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'operating_hours': operatingHours,
        'capacity': capacity,
        'status': status,
      };
      
      developer.log('Dữ liệu gửi đi: $body');
      
      final response = await apiClient.post(
        ApiConstants.collectionPoints,
        body: body,
      );
      
      developer.log('Phản hồi từ API: Mã trạng thái ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Dữ liệu phản hồi: $data');
        
        if (data['status'] == 'success' && data['data'] != null && data['data']['collectionPoint'] != null) {
          final Map<String, dynamic> collectionPointJson = data['data']['collectionPoint'];
          return CollectionPoint.fromJson(collectionPointJson);
        } else {
          developer.log('Không thể tạo điểm thu gom: ${data['message'] ?? 'Lỗi không xác định'}');
          return null;
        }
      } else {
        developer.log('Lỗi khi tạo điểm thu gom. Mã trạng thái: ${response.statusCode}', 
          error: 'Lỗi HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      developer.log('Lỗi khi tạo điểm thu gom: $e', error: e);
      throw Exception('Không thể tạo điểm thu gom: $e');
    }
  }
} 