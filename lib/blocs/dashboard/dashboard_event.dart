abstract class DashboardEvent {
  const DashboardEvent();
}

class LoadDashboard extends DashboardEvent {
  final int userId;
  
  const LoadDashboard({required this.userId});
}

class RefreshDashboard extends DashboardEvent {
  final int userId;
  
  const RefreshDashboard({required this.userId});
} 