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
    return Reward(
      rewardId: json['reward_id'],
      points: json['points'],
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
    return RewardStatistics(
      period: json['period'],
      totalPoints: json['total_points'],
      rewardCount: json['reward_count'],
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
    return UserRanking(
      userId: json['user_id'],
      username: json['username'],
      fullName: json['full_name'],
      totalPoints: json['total_points'],
      rank: json['rank'],
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
    return Pagination(
      currentPage: json['current_page'],
      totalPages: json['total_pages'],
      totalItems: json['total_items'],
      itemsPerPage: json['items_per_page'],
    );
  }
} 