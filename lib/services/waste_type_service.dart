import 'dart:convert';
import '../core/api/api_client.dart';
import '../models/waste_type_model.dart';

class WasteTypeService {
  final ApiClient apiClient;

  WasteTypeService({required this.apiClient});

  Future<List<WasteType>> getAllWasteTypes() async {
    try {
      final response = await apiClient.get('/waste-types');
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        List<dynamic> wasteTypeList = data['data'];
        return wasteTypeList.map((json) => WasteType.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load waste types');
      }
    } catch (e) {
      throw Exception('Error fetching waste types: $e');
    }
  }

  Future<WasteType> getWasteTypeById(int id) async {
    try {
      final response = await apiClient.get('/waste-types/$id');
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return WasteType.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to load waste type');
      }
    } catch (e) {
      throw Exception('Error fetching waste type: $e');
    }
  }

  Future<WasteType> createWasteType(Map<String, dynamic> wasteTypeData) async {
    try {
      final response = await apiClient.post(
        '/waste-types', 
        body: wasteTypeData,
      );
      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        return WasteType.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create waste type');
      }
    } catch (e) {
      throw Exception('Error creating waste type: $e');
    }
  }

  Future<WasteType> updateWasteType(int id, Map<String, dynamic> wasteTypeData) async {
    try {
      final response = await apiClient.put(
        '/waste-types/$id', 
        body: wasteTypeData,
      );
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return WasteType.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to update waste type');
      }
    } catch (e) {
      throw Exception('Error updating waste type: $e');
    }
  }

  Future<bool> deleteWasteType(int id) async {
    try {
      final response = await apiClient.delete('/waste-types/$id');
      
      if (response.statusCode == 204) {
        return true;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete waste type');
      }
    } catch (e) {
      throw Exception('Error deleting waste type: $e');
    }
  }
} 