import '../models/waste_type_model.dart';
import '../models/recycling_goal_model.dart';
import '../models/recent_activity_model.dart';
import '../models/transaction_model.dart';
import 'dart:convert';

class DashboardRepository {
  // In a real app, this would make API calls to your backend
  // For now, we'll simulate with mock data
  
  Future<double> getTotalWasteAmount(int userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data
    return 32.5; // 32.5kg
  }
  
  Future<double> getMonthlyGoalProgress(int userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data - 75% of goal
    return 75.0;
  }
  
  Future<RecyclingGoal> getMonthlyGoal(int userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data
    return RecyclingGoal(
      userId: userId,
      targetAmount: 50.0,
      period: 'monthly',
      startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
      endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
      currentAmount: 32.5,
    );
  }
  
  Future<List<RecentActivity>> getRecentActivities(int userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock data
    return [
      RecentActivity(
        id: 1,
        userId: userId,
        activityType: 'waste_sorting',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        description: 'Phân loại thành công',
        iconType: 'check_circle',
        details: {
          'waste_type_id': 1,
          'waste_name': 'nhựa',
          'quantity': 2.5,
          'unit': 'kg',
        },
      ),
      RecentActivity(
        id: 2,
        userId: userId,
        activityType: 'waste_sorting',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        description: 'Phân loại thành công',
        iconType: 'check_circle',
        details: {
          'waste_type_id': 2,
          'waste_name': 'giấy',
          'quantity': 1.8,
          'unit': 'kg',
        },
      ),
      RecentActivity(
        id: 3,
        userId: userId,
        activityType: 'points_earned',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Nhận điểm thưởng',
        iconType: 'points',
        details: {
          'points': 120,
        },
      ),
    ];
  }
} 