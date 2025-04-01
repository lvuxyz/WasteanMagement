class RecyclingGoal {
  final int userId;
  final double targetAmount;
  final String period; // 'weekly', 'monthly'
  final DateTime startDate;
  final DateTime endDate;
  final double currentAmount;

  RecyclingGoal({
    required this.userId,
    required this.targetAmount,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.currentAmount = 0,
  });

  double get progressPercentage => 
    targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
  
  double get remainingAmount => 
    targetAmount > currentAmount ? targetAmount - currentAmount : 0;

  factory RecyclingGoal.fromJson(Map<String, dynamic> json) {
    return RecyclingGoal(
      userId: json['user_id'],
      targetAmount: (json['target_amount'] as num).toDouble(),
      period: json['period'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'target_amount': targetAmount,
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'current_amount': currentAmount,
    };
  }
} 