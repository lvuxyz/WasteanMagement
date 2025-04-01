import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    
    try {
      final totalWaste = await repository.getTotalWasteAmount(event.userId);
      final progressPercentage = await repository.getMonthlyGoalProgress(event.userId);
      final monthlyGoal = await repository.getMonthlyGoal(event.userId);
      final recentActivities = await repository.getRecentActivities(event.userId);
      
      emit(DashboardLoaded(
        totalWaste: totalWaste,
        progressPercentage: progressPercentage,
        monthlyGoal: monthlyGoal,
        recentActivities: recentActivities,
      ));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final currentState = state;
      
      if (currentState is DashboardLoaded) {
        // Keep current state while refreshing in background
        final totalWaste = await repository.getTotalWasteAmount(event.userId);
        final progressPercentage = await repository.getMonthlyGoalProgress(event.userId);
        final monthlyGoal = await repository.getMonthlyGoal(event.userId);
        final recentActivities = await repository.getRecentActivities(event.userId);
        
        emit(DashboardLoaded(
          totalWaste: totalWaste,
          progressPercentage: progressPercentage,
          monthlyGoal: monthlyGoal,
          recentActivities: recentActivities,
        ));
      } else {
        await _onLoadDashboard(LoadDashboard(userId: event.userId), emit);
      }
    } catch (e) {
      // If refresh fails, stay with current state and don't show error
      if (state is! DashboardLoaded) {
        emit(DashboardError(message: e.toString()));
      }
    }
  }
} 