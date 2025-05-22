import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reward.dart';
import '../core/api/api_constants.dart';
import '../services/auth_service.dart';
import 'dart:developer' as developer;

class RewardService {
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
    
    // Use a more structured way to build query parameters
    final Uri uri = Uri.parse('${ApiConstants.rewards}/my-rewards');
    
    // Build query parameters with proper encoding
    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    // Add date parameters if provided
    if (fromDate != null) queryParams['from_date'] = fromDate;
    if (toDate != null) queryParams['to_date'] = toDate;
    
    // Create the final URL with encoded parameters
    final finalUri = uri.replace(queryParameters: queryParams);
    
    // Log the URL for debugging
    developer.log('Requesting rewards with URL: $finalUri');
    
    final response = await http.get(finalUri, headers: headers);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      
      // Log received data for debugging
      developer.log('Received ${(data['rewards'] as List).length} rewards');
      if (fromDate != null || toDate != null) {
        developer.log('Filter applied - From: $fromDate, To: $toDate');
        
        // Check the first and last dates in the response to confirm filtering worked
        if ((data['rewards'] as List).isNotEmpty) {
          final firstReward = Reward.fromJson((data['rewards'] as List).first);
          final lastReward = Reward.fromJson((data['rewards'] as List).last);
          developer.log('First reward date: ${firstReward.earnedDate}, Last reward date: ${lastReward.earnedDate}');
        }
      }
      
      return {
        'rewards': (data['rewards'] as List).map((e) => Reward.fromJson(e)).toList(),
        'totalPoints': data['total_points'],
        'pagination': Pagination.fromJson(data['pagination']),
      };
    } else {
      developer.log('Error loading rewards: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load rewards: ${response.body}');
    }
  }

  // Get user's total points
  Future<int> getMyTotalPoints() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('${ApiConstants.rewards}/my-total-points'),
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
      Uri.parse('${ApiConstants.rewards}/my-statistics?period=$period'),
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
    final response = await http.get(Uri.parse('${ApiConstants.rewards}/rankings'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((item) => UserRanking.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load rankings: ${response.body}');
    }
  }

  // Get reward details
  Future<Reward> getRewardDetails(int rewardId) async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('${ApiConstants.rewards}/$rewardId'),
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
      Uri.parse('${ApiConstants.rewards}/users/$userId?page=$page&limit=$limit'),
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
      Uri.parse(ApiConstants.rewards),
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
      Uri.parse('${ApiConstants.rewards}/$rewardId'),
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
      Uri.parse('${ApiConstants.rewards}/$rewardId'),
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
      Uri.parse('${ApiConstants.rewards}/transactions/$transactionId/process'),
      headers: headers,
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Reward.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to process transaction reward: ${response.body}');
    }
  }
} 