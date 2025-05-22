import '../models/waste_type_model.dart';
import '../models/collection_point.dart';
import '../core/api/api_constants.dart';
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
      developer.log('Fetching waste type details from API: ${ApiConstants.wasteTypes}/$wasteTypeId');
      
      final response = await apiClient.get('${ApiConstants.wasteTypes}/$wasteTypeId');
      
      developer.log('API response status code: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Response data: $data');
        
        if (data['status'] == 'success' && data['data'] != null && data['data']['wasteType'] != null) {
          final Map<String, dynamic> wasteTypeJson = data['data']['wasteType'];
          return WasteType.fromJson(wasteTypeJson);
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          developer.log('API error: $errorMessage', error: errorMessage);
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to load waste type details. Status code: ${response.statusCode}';
        developer.log(errorMessage, error: 'HTTP Error ${response.statusCode}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log('Error fetching waste type details: $e', error: e);
      throw Exception('Failed to load waste type details: $e');
    }
  }

  // Phương thức lấy danh sách điểm thu gom cho một loại rác
  Future<List<CollectionPoint>> getCollectionPointsForWasteType(int wasteTypeId) async {
    try {
      developer.log('Đang gọi API lấy điểm thu gom cho loại rác: ${ApiConstants.wasteTypes}/$wasteTypeId/collection-points');
      
      final response = await apiClient.get('${ApiConstants.wasteTypes}/$wasteTypeId/collection-points');
      
      developer.log('Phản hồi từ API: Mã trạng thái ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Dữ liệu phản hồi: $data');
        
        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> collectionPointsJson = data['data']['collectionPoints'];
          return collectionPointsJson.map((json) => CollectionPoint.fromJson(json)).toList();
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          developer.log('API error: $errorMessage', error: errorMessage);
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to load collection points. Status code: ${response.statusCode}';
        developer.log(errorMessage, error: 'HTTP Error ${response.statusCode}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log('Error fetching collection points: $e', error: e);
      throw Exception('Failed to load collection points: $e');
    }
  }

  // Phương thức lấy tất cả các điểm thu gom
  Future<List<CollectionPoint>> getAllCollectionPoints() async {
    try {
      developer.log('Đang gọi API lấy tất cả điểm thu gom: ${ApiConstants.baseUrl}/collection-points');
      
      final response = await apiClient.get('${ApiConstants.baseUrl}/collection-points');
      
      developer.log('Phản hồi từ API: Mã trạng thái ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Dữ liệu phản hồi: $data');
        
        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> collectionPointsJson = data['data']['collectionPoints'];
          return collectionPointsJson.map((json) => CollectionPoint.fromJson(json)).toList();
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          developer.log('API error: $errorMessage', error: errorMessage);
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to load all collection points. Status code: ${response.statusCode}';
        developer.log(errorMessage, error: 'HTTP Error ${response.statusCode}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log('Error fetching all collection points: $e', error: e);
      throw Exception('Failed to load all collection points: $e');
    }
  }

  // Phương thức xóa loại rác
  Future<bool> deleteWasteType(int wasteTypeId) async {
    try {
      developer.log('Đang gọi API xóa loại rác: ${ApiConstants.wasteTypes}/$wasteTypeId');
      
      final response = await apiClient.delete('${ApiConstants.wasteTypes}/$wasteTypeId');
      
      developer.log('Đang xử lý phản hồi với mã: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // For 204 No Content, the response will be empty
        if (response.statusCode == 204) {
          return true;
        }
        
        // For other successful status codes, check the response data
        final data = response.data;
        developer.log('Dữ liệu phản hồi: $data');
        
        // Consider 'success' status as successful
        if (data['status'] == 'success') {
          return true;
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          developer.log('API error: $errorMessage', error: errorMessage);
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to delete waste type. Status code: ${response.statusCode}';
        developer.log(errorMessage, error: 'HTTP Error ${response.statusCode}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log('Error deleting waste type: $e', error: e);
      throw Exception('Failed to delete waste type: $e');
    }
  }

  // Phương thức liên kết loại rác với điểm thu gom
  Future<bool> linkCollectionPoint(int wasteTypeId, int collectionPointId) async {
    try {
      developer.log('Đang gọi API liên kết loại rác với điểm thu gom: ${ApiConstants.baseUrl}/waste-types/collection-point');
      
      final Map<String, dynamic> requestBody = {
        'waste_type_id': wasteTypeId,
        'collection_point_id': collectionPointId,
      };
      
      developer.log('Dữ liệu gửi đi: $requestBody');
      
      final response = await apiClient.post('${ApiConstants.baseUrl}/waste-types/collection-point', body: requestBody);
      
      developer.log('Phản hồi từ API: Mã trạng thái ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Dữ liệu phản hồi: $data');
        
        if (data['status'] == 'success') {
          return true;
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          developer.log('API error: $errorMessage', error: errorMessage);
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to link waste type with collection point. Status code: ${response.statusCode}';
        developer.log(errorMessage, error: 'HTTP Error ${response.statusCode}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log('Error linking waste type with collection point: $e', error: e);
      throw Exception('Failed to link waste type with collection point: $e');
    }
  }

  // Phương thức hủy liên kết loại rác với điểm thu gom
  Future<bool> unlinkCollectionPoint(int wasteTypeId, int collectionPointId) async {
    try {
      developer.log('Đang gọi API hủy liên kết loại rác với điểm thu gom');
      
      // Chuẩn bị query params cho DELETE request
      final url = '${ApiConstants.baseUrl}/waste-types/collection-point?waste_type_id=$wasteTypeId&collection_point_id=$collectionPointId';
      
      developer.log('URL yêu cầu: $url');
      
      final response = await apiClient.delete(url);
      
      developer.log('Phản hồi từ API: Mã trạng thái ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Dữ liệu phản hồi: $data');
        
        if (data['status'] == 'success') {
          return true;
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          developer.log('API error: $errorMessage', error: errorMessage);
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to unlink waste type from collection point. Status code: ${response.statusCode}';
        developer.log(errorMessage, error: 'HTTP Error ${response.statusCode}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log('Error unlinking waste type from collection point: $e', error: e);
      throw Exception('Failed to unlink waste type from collection point: $e');
    }
  }
  
  // Phương thức tạo loại rác mới
  Future<WasteType> createWasteType(Map<String, dynamic> wasteTypeData) async {
    try {
      developer.log('Đang gọi API tạo loại rác mới: ${ApiConstants.wasteTypes}');
      developer.log('Dữ liệu gửi đi: $wasteTypeData');
      
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
      
      developer.log('Phản hồi từ API: Mã trạng thái ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Dữ liệu phản hồi: $data');
        
        if (data['status'] == 'success' && data['data'] != null && data['data']['wasteType'] != null) {
          final Map<String, dynamic> wasteTypeJson = data['data']['wasteType'];
          return WasteType.fromJson(wasteTypeJson);
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          developer.log('API error: $errorMessage', error: errorMessage);
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to create waste type. Status code: ${response.statusCode}';
        developer.log(errorMessage, error: 'HTTP Error ${response.statusCode}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log('Error creating waste type: $e', error: e);
      throw Exception('Failed to create waste type: $e');
    }
  }
  
  // Phương thức cập nhật loại rác
  Future<WasteType> updateWasteType(int wasteTypeId, Map<String, dynamic> updateData) async {
    try {
      developer.log('Đang gọi API cập nhật loại rác: ${ApiConstants.wasteTypes}/$wasteTypeId');
      developer.log('Dữ liệu gửi đi: $updateData');
      
      final response = await apiClient.patch('${ApiConstants.wasteTypes}/$wasteTypeId', body: updateData);
      
      developer.log('Phản hồi từ API: Mã trạng thái ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Dữ liệu phản hồi: $data');
        
        if (data['status'] == 'success' && data['data'] != null && data['data']['wasteType'] != null) {
          final Map<String, dynamic> wasteTypeJson = data['data']['wasteType'];
          return WasteType.fromJson(wasteTypeJson);
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          developer.log('API error: $errorMessage', error: errorMessage);
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to update waste type. Status code: ${response.statusCode}';
        developer.log(errorMessage, error: 'HTTP Error ${response.statusCode}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log('Error updating waste type: $e', error: e);
      throw Exception('Failed to update waste type: $e');
    }
  }

  Future<List<WasteType>> getWasteTypesForCollectionPoint(int collectionPointId) async {
    try {
      developer.log('Đang gọi API lấy loại rác cho điểm thu gom: ${ApiConstants.baseUrl}/waste-types/collection-point/$collectionPointId');
      
      final response = await apiClient.get('${ApiConstants.baseUrl}/waste-types/collection-point/$collectionPointId');
      
      developer.log('Phản hồi từ API: Mã trạng thái ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Dữ liệu phản hồi: $data');
        
        if (data['status'] == 'success' && data['data'] != null && data['data']['wasteTypes'] != null) {
          final List<dynamic> wasteTypesJson = data['data']['wasteTypes'];
          return wasteTypesJson.map((json) => WasteType.fromJson(json)).toList();
        } else {
          final errorMessage = data['message'] ?? 'Unknown API error';
          developer.log('API error: $errorMessage', error: errorMessage);
          throw Exception('API error: $errorMessage');
        }
      } else {
        final errorMessage = 'Failed to load waste types for collection point. Status code: ${response.statusCode}';
        developer.log(errorMessage, error: 'HTTP Error ${response.statusCode}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log('Error fetching waste types for collection point: $e', error: e);
      throw Exception('Failed to load waste types for collection point: $e');
    }
  }

  Future<List<WasteType>> getAllWasteTypes() async {
    try {
      developer.log('Đang gọi API ${ApiConstants.wasteTypes}');
      
      // Sử dụng apiClient thay vì http trực tiếp để đảm bảo token được gửi kèm
      final response = await apiClient.get(ApiConstants.wasteTypes);
      
      developer.log('Phản hồi từ API: Mã trạng thái ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.data;
        
        developer.log('Dữ liệu phản hồi: $data');
        
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
          developer.log('Lỗi API: $errorMessage', error: errorMessage);
          throw Exception('API error: $errorMessage');
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
}