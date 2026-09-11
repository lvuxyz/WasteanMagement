import '../core/api/api_constants.dart';
import '../core/api/api_client.dart';
import '../models/collection_point.dart';
import '../utils/app_logger.dart';

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
      AppLogger.w('CollectionPoint', 'Không lấy được điểm thu gom của loại rác: $e');
      throw Exception('Failed to load collection points: $e');
    }
  }

  // Lấy chi tiết điểm thu gom
  Future<CollectionPoint?> getCollectionPointById(int id) async {
    try {
      final response = await apiClient.get('${ApiConstants.collectionPoints}/$id');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;

        if (data['status'] == 'success' && data['data'] != null && data['data']['collectionPoint'] != null) {
          final Map<String, dynamic> collectionPointJson = data['data']['collectionPoint'];
          return CollectionPoint.fromJson(collectionPointJson);
        } else {
          AppLogger.w('CollectionPoint', 'Phản hồi API không có chi tiết điểm thu gom');
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      AppLogger.e('CollectionPoint', 'Lỗi khi tải chi tiết điểm thu gom', error: e);
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
      final body = {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'operating_hours': operatingHours,
        'capacity': capacity,
        'status': status,
      };

      AppLogger.d('CollectionPoint', 'Gửi dữ liệu · ${AppLogger.preview(body)}');

      final response = await apiClient.post(
        ApiConstants.collectionPoints,
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;

        if (data['status'] == 'success' && data['data'] != null && data['data']['collectionPoint'] != null) {
          final Map<String, dynamic> collectionPointJson = data['data']['collectionPoint'];
          return CollectionPoint.fromJson(collectionPointJson);
        } else {
          AppLogger.w('CollectionPoint', 'Không thể tạo điểm thu gom: ${data['message'] ?? 'Lỗi không xác định'}');
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      AppLogger.e('CollectionPoint', 'Lỗi khi tạo điểm thu gom', error: e);
      throw Exception('Không thể tạo điểm thu gom: $e');
    }
  }
} 