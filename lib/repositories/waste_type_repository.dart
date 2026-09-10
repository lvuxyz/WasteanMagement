import '../models/waste_type_model.dart';
import '../models/collection_point.dart';
import '../core/api/api_constants.dart';
import '../core/api/api_client.dart';
import '../utils/app_logger.dart';

class WasteTypeRepository {
  final ApiClient apiClient;
  final String baseUrl = ApiConstants.baseUrl;

  WasteTypeRepository({required this.apiClient});

  Future<List<WasteType>> getWasteTypes() async {
    try {
      final response = await apiClient.get(ApiConstants.wasteTypes);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;

        if (data['status'] == 'success') {
          final List<dynamic> wasteTypesJson = data['data']['wasteTypes'];
          return wasteTypesJson.map((json) => WasteType.fromJson(json)).toList();
        } else {
          AppLogger.w('WasteType', 'API báo lỗi: ${data['message']}');
          throw Exception('API error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load waste types. Status code: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.e('WasteType', 'Lỗi khi tải danh sách loại rác', error: e);
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
      final response = await apiClient.get('${ApiConstants.wasteTypes}/$wasteTypeId');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;

        if (data['status'] == 'success' && data['data'] != null && data['data']['wasteType'] != null) {
          final Map<String, dynamic> wasteTypeJson = data['data']['wasteType'];
          return WasteType.fromJson(wasteTypeJson);
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          AppLogger.w('WasteType', 'API báo lỗi: $errorMessage');
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to load waste type details. Status code: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.e('WasteType', 'Không lấy được chi tiết loại rác', error: e);
      throw Exception('Failed to load waste type details: $e');
    }
  }

  // Phương thức lấy danh sách điểm thu gom cho một loại rác
  Future<List<CollectionPoint>> getCollectionPointsForWasteType(int wasteTypeId) async {
    try {
      final response = await apiClient.get('${ApiConstants.wasteTypes}/$wasteTypeId/collection-points');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;

        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> collectionPointsJson = data['data']['collectionPoints'];
          return collectionPointsJson.map((json) => CollectionPoint.fromJson(json)).toList();
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          AppLogger.w('WasteType', 'API báo lỗi: $errorMessage');
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to load collection points. Status code: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.e('WasteType', 'Không lấy được điểm thu gom của loại rác', error: e);
      throw Exception('Failed to load collection points: $e');
    }
  }

  // Phương thức lấy tất cả các điểm thu gom
  Future<List<CollectionPoint>> getAllCollectionPoints() async {
    try {
      final response = await apiClient.get('${ApiConstants.baseUrl}/collection-points');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;

        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> collectionPointsJson = data['data']['collectionPoints'];
          return collectionPointsJson.map((json) => CollectionPoint.fromJson(json)).toList();
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          AppLogger.w('WasteType', 'API báo lỗi: $errorMessage');
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to load all collection points. Status code: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.e('WasteType', 'Không lấy được toàn bộ điểm thu gom', error: e);
      throw Exception('Failed to load all collection points: $e');
    }
  }

  // Phương thức xóa loại rác
  Future<bool> deleteWasteType(int wasteTypeId) async {
    try {
      final response = await apiClient.delete('${ApiConstants.wasteTypes}/$wasteTypeId');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // For 204 No Content, the response will be empty
        if (response.statusCode == 204) {
          return true;
        }

        // For other successful status codes, check the response data
        final data = response.data;

        // Consider 'success' status as successful
        if (data['status'] == 'success') {
          return true;
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          AppLogger.w('WasteType', 'API báo lỗi: $errorMessage');
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to delete waste type. Status code: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.e('WasteType', 'Không xóa được loại rác', error: e);
      throw Exception('Failed to delete waste type: $e');
    }
  }

  // Phương thức liên kết loại rác với điểm thu gom
  Future<bool> linkCollectionPoint(int wasteTypeId, int collectionPointId) async {
    try {
      final Map<String, dynamic> requestBody = {
        'waste_type_id': wasteTypeId,
        'collection_point_id': collectionPointId,
      };

      AppLogger.d('WasteType', 'Gửi dữ liệu · ${AppLogger.preview(requestBody)}');

      final response = await apiClient.post('${ApiConstants.baseUrl}/waste-types/collection-point', body: requestBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;

        if (data['status'] == 'success') {
          return true;
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          AppLogger.w('WasteType', 'API báo lỗi: $errorMessage');
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to link waste type with collection point. Status code: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.e('WasteType', 'Không liên kết được loại rác với điểm thu gom', error: e);
      throw Exception('Failed to link waste type with collection point: $e');
    }
  }

  // Phương thức hủy liên kết loại rác với điểm thu gom
  Future<bool> unlinkCollectionPoint(int wasteTypeId, int collectionPointId) async {
    try {
      // Sử dụng mẫu URL với path parameters thay vì query parameters
      final url = '${ApiConstants.baseUrl}/waste-types/collection-point/$collectionPointId/$wasteTypeId';

      final response = await apiClient.delete(url);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // For 204 No Content, the response will be empty
        if (response.statusCode == 204) {
          return true;
        }

        // For other successful status codes, check the response data
        final data = response.data;

        if (data['status'] == 'success') {
          return true;
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          AppLogger.w('WasteType', 'API báo lỗi: $errorMessage');
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to unlink waste type from collection point. Status code: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.e('WasteType', 'Không hủy được liên kết loại rác với điểm thu gom', error: e);
      throw Exception('Failed to unlink waste type from collection point: $e');
    }
  }

  // Phương thức tạo loại rác mới
  Future<WasteType> createWasteType(Map<String, dynamic> wasteTypeData) async {
    try {
      AppLogger.d('WasteType', 'Gửi dữ liệu · ${AppLogger.preview(wasteTypeData)}');

      // Ensure API consistency by transforming the data if needed
      Map<String, dynamic> apiData = {
        'name': wasteTypeData['name'],
        'description': wasteTypeData['description'],
        'recyclable': wasteTypeData['recyclable'],
        'handling_instructions': wasteTypeData['handling_instructions'],
        'unit_price': wasteTypeData['unit_price'],
        'category': wasteTypeData['category'],
        'unit': wasteTypeData['unit'] ?? 'kg',
      };

      // Convert examples list to proper format for API
      if (wasteTypeData['examples'] != null) {
        apiData['examples'] = wasteTypeData['examples'];
      }

      final response = await apiClient.post(ApiConstants.wasteTypes, body: apiData);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;

        if (data['status'] == 'success' && data['data'] != null && data['data']['wasteType'] != null) {
          final Map<String, dynamic> wasteTypeJson = data['data']['wasteType'];
          return WasteType.fromJson(wasteTypeJson);
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          AppLogger.w('WasteType', 'API báo lỗi: $errorMessage');
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to create waste type. Status code: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.e('WasteType', 'Không tạo được loại rác', error: e);
      throw Exception('Failed to create waste type: $e');
    }
  }

  // Phương thức cập nhật loại rác
  Future<WasteType> updateWasteType(int wasteTypeId, Map<String, dynamic> updateData) async {
    try {
      AppLogger.d('WasteType', 'Gửi dữ liệu · ${AppLogger.preview(updateData)}');

      final response = await apiClient.patch('${ApiConstants.wasteTypes}/$wasteTypeId', body: updateData);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;

        if (data['status'] == 'success' && data['data'] != null && data['data']['wasteType'] != null) {
          final Map<String, dynamic> wasteTypeJson = data['data']['wasteType'];
          return WasteType.fromJson(wasteTypeJson);
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          AppLogger.w('WasteType', 'API báo lỗi: $errorMessage');
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to update waste type. Status code: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.e('WasteType', 'Không cập nhật được loại rác', error: e);
      throw Exception('Failed to update waste type: $e');
    }
  }

  Future<List<WasteType>> getWasteTypesForCollectionPoint(int collectionPointId) async {
    try {
      final response = await apiClient.get('${ApiConstants.baseUrl}/waste-types/collection-point/$collectionPointId');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;

        if (data['status'] == 'success' && data['data'] != null && data['data']['wasteTypes'] != null) {
          final List<dynamic> wasteTypesJson = data['data']['wasteTypes'];
          return wasteTypesJson.map((json) => WasteType.fromJson(json)).toList();
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          AppLogger.w('WasteType', 'API báo lỗi: $errorMessage');
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to load waste types for collection point. Status code: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.e('WasteType', 'Không lấy được loại rác của điểm thu gom', error: e);
      throw Exception('Failed to load waste types for collection point: $e');
    }
  }

  Future<List<WasteType>> getAllWasteTypes() async {
    try {
      // Sử dụng apiClient thay vì http trực tiếp để đảm bảo token được gửi kèm
      final response = await apiClient.get(ApiConstants.wasteTypes);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;

        List<dynamic> wasteTypesJson;

        // Handle different API response formats
        if (data['status'] == 'success' && data['data'] != null) {
          if (data['data'] is List) {
            wasteTypesJson = data['data'];
          } else if (data['data'] is Map && data['data']['wasteTypes'] != null) {
            wasteTypesJson = data['data']['wasteTypes'];
          } else {
            throw Exception('Unexpected data format from API');
          }

          final wasteTypes = wasteTypesJson
              .map((json) => WasteType.fromJson(json))
              .toList();

          return wasteTypes;
        } else {
          final errorMessage = data['message'] ?? 'Không thể tải danh sách loại rác';
          AppLogger.e('WasteType', 'Lỗi API', error: errorMessage);
          throw Exception('API error: $errorMessage');
        }
      } else {
        throw Exception('Failed to load waste types. Status code: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.e('WasteType', 'Lỗi khi tải danh sách loại rác', error: e);
      throw Exception('Failed to load waste types: $e');
    }
  }
}