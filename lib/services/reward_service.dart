import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reward.dart';
import '../core/api/api_constants.dart';
import '../services/auth_service.dart';

class RewardService {
  final String baseUrl = '${ApiConstants.baseUrl}/rewards';
  final AuthService _authService = AuthService();

  // Get authenticated headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get user's reward history
  Future<Map<String, dynamic>> getMyRewards({
    int page = 1, 
    int limit = 10, 
    String? fromDate, 
    String? toDate
  }) async {
    final headers = await _getHeaders();
    
    String url = '$baseUrl/my-rewards?page=$page&limit=$limit';
    if (fromDate != null) url += '&from_date=$fromDate';
    if (toDate != null) url += '&to_date=$toDate';
    
    final response = await http.get(Uri.parse(url), headers: headers);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      
      return {
        'rewards': (data['rewards'] as List).map((e) => Reward.fromJson(e)).toList(),
        'totalPoints': data['total_points'],
        'pagination': Pagination.fromJson(data['pagination']),
      };
    } else {
      throw Exception('Failed to load rewards: ${response.body}');
    }
  }

  // Get user's total points
  Future<int> getMyTotalPoints() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/my-total-points'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body)['data']['total_points'];
    } else {
      throw Exception('Failed to load total points: ${response.body}');
    }
  }

  // Get user's reward statistics
  Future<Map<String, dynamic>> getMyStatistics({String period = 'monthly'}) async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/my-statistics?period=$period'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      
      return {
        'period': data['period'],
        'statistics': (data['statistics'] as List)
            .map((e) => RewardStatistics.fromJson(e))
            .toList(),
      };
    } else {
      throw Exception('Failed to load statistics: ${response.body}');
    }
  }

  // Get user rankings
  Future<List<UserRanking>> getUserRankings() async {
    final response = await http.get(Uri.parse('$baseUrl/rankings'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.asMap().entries.map((entry) {
        return UserRanking.fromJson(entry.value, entry.key + 1);
      }).toList();
    } else {
      throw Exception('Failed to load rankings: ${response.body}');
    }
  }

  // Get reward details
  Future<Reward> getRewardDetails(int rewardId) async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/$rewardId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return Reward.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to load reward details: ${response.body}');
    }
  }
  
  // Admin methods
  
  // Get user's rewards (admin only)
  Future<Map<String, dynamic>> getUserRewardsAdmin(int userId, {int page = 1, int limit = 10}) async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId?page=$page&limit=$limit'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      
      return {
        'rewards': (data['rewards'] as List)
            .map((e) => Reward.fromJson(e))
            .toList(),
        'pagination': Pagination.fromJson(data['pagination']),
      };
    } else {
      throw Exception('Failed to load user rewards: ${response.body}');
    }
  }
  
  // Create reward (admin only)
  Future<Reward> createReward(int userId, int points, {int? transactionId}) async {
    final headers = await _getHeaders();
    
    final body = {
      'user_id': userId,
      'points': points,
    };
    
    if (transactionId != null) {
      body['transaction_id'] = transactionId;
    }
    
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode(body),
    );
    
    if (response.statusCode == 201) {
      return Reward.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to create reward: ${response.body}');
    }
  }
  
  // Update reward (admin only)
  Future<Reward> updateReward(int rewardId, int points) async {
    final headers = await _getHeaders();
    
    final response = await http.put(
      Uri.parse('$baseUrl/$rewardId'),
      headers: headers,
      body: json.encode({'points': points}),
    );
    
    if (response.statusCode == 200) {
      return Reward.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to update reward: ${response.body}');
    }
  }
  
  // Delete reward (admin only)
  Future<bool> deleteReward(int rewardId) async {
    final headers = await _getHeaders();
    
    final response = await http.delete(
      Uri.parse('$baseUrl/$rewardId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete reward: ${response.body}');
    }
  }
  
  // Process reward for transaction (admin only)
  Future<Reward> processTransactionReward(int transactionId) async {
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/$transactionId/process'),
      headers: headers,
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Reward.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to process transaction reward: ${response.body}');
    }
  }
} 