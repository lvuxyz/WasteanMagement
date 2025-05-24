class Reward {
  final int rewardId;
  final int points;
  final String source;
  final DateTime earnedDate;
  final DateTime? transactionDate;
  final String? transactionId;

  Reward({
    required this.rewardId,
    required this.points,
    required this.source,
    required this.earnedDate,
    this.transactionDate,
    this.transactionId,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert values to int
    int parseIntValue(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return Reward(
      rewardId: parseIntValue(json['reward_id']),
      points: parseIntValue(json['points']),
      source: json['source'] ?? 'Manual Reward',
      earnedDate: DateTime.parse(json['earned_date']),
      transactionDate: json['transaction_date'] != null 
        ? DateTime.parse(json['transaction_date']) 
        : null,
      transactionId: json['transaction_id']?.toString(),
    );
  }
}

class RewardStatistics {
  final String period;
  final int totalPoints;
  final int rewardCount;

  RewardStatistics({
    required this.period,
    required this.totalPoints,
    required this.rewardCount,
  });

  factory RewardStatistics.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert values to int
    int parseIntValue(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return RewardStatistics(
      period: json['period'] ?? '',
      totalPoints: parseIntValue(json['total_points']),
      rewardCount: parseIntValue(json['reward_count']),
    );
  }
}

class UserRanking {
  final int userId;
  final String? username;
  final String? fullName;
  final int totalPoints;
  final int rank;
  
  UserRanking({
    required this.userId,
    this.username,
    this.fullName,
    required this.totalPoints,
    required this.rank,
  });
  
  factory UserRanking.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert values to int
    int parseIntValue(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return UserRanking(
      userId: parseIntValue(json['user_id']),
      username: json['username'],
      fullName: json['full_name'],
      totalPoints: parseIntValue(json['total_points']),
      rank: parseIntValue(json['rank']),
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert values to int
    int parseIntValue(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return Pagination(
      currentPage: parseIntValue(json['current_page']),
      totalPages: parseIntValue(json['total_pages']),
      totalItems: parseIntValue(json['total_items']),
      itemsPerPage: parseIntValue(json['items_per_page']),
    );
  }
} 