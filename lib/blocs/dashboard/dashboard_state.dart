import '../../models/recycling_goal_model.dart';
import '../../models/recent_activity_model.dart';

abstract class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final double totalWaste;
  final double progressPercentage;
  final RecyclingGoal monthlyGoal;
  final List<RecentActivity> recentActivities;
  
  const DashboardLoaded({
    required this.totalWaste,
    required this.progressPercentage,
    required this.monthlyGoal,
    required this.recentActivities,
  });
}

class DashboardError extends DashboardState {
  final String message;
  
  const DashboardError({required this.message});
} 