import '../models/transaction_model.dart';

class RecentActivity {
  final int id;
  final int userId;
  final String activityType; // 'waste_sorting', 'recycling', 'point_earned'
  final DateTime timestamp;
  final String description;
  final Map<String, dynamic> details;
  final String iconType;

  RecentActivity({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.timestamp,
    required this.description,
    this.details = const {},
    required this.iconType,
  });

  factory RecentActivity.fromTransaction(Transaction transaction) {
    return RecentActivity(
      id: transaction.id,
      userId: transaction.userId,
      activityType: 'waste_sorting',
      timestamp: transaction.transactionDate,
      description: 'Phân loại thành công',
      details: {
        'waste_type_id': transaction.wasteTypeId,
        'waste_name': transaction.wasteName,
        'quantity': transaction.quantity,
        'unit': transaction.unit,
      },
      iconType: 'check_circle',
    );
  }

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'],
      userId: json['user_id'],
      activityType: json['activity_type'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      details: json['details'] ?? {},
      iconType: json['icon_type'] ?? 'info',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_type': activityType,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'details': details,
      'icon_type': iconType,
    };
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
} 