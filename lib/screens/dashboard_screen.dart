import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../blocs/dashboard/dashboard_event.dart';
import '../blocs/dashboard/dashboard_state.dart';
import '../widgets/dashboard/waste_summary_card.dart';
import '../widgets/dashboard/recycling_goal_card.dart';
import '../widgets/dashboard/quick_action_button.dart';
import '../widgets/dashboard/recent_activity_item.dart';
import '../widgets/common/custom_bottom_navigation.dart';
import '../repositories/dashboard_repository.dart';
import '../utils/app_colors.dart';
import '../screens/waste_detection_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // In a real app, you would get the userId from auth
    const userId = 1;
    
    return BlocProvider(
      create: (context) => DashboardBloc(
        repository: DashboardRepository(),
      )..add(const LoadDashboard(userId: userId)),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          title: Row(
            children: [
              Text(
                'Xin chào, Minh!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(
                    const RefreshDashboard(userId: userId),
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Waste summary card
                      WasteSummaryCard(
                        totalWaste: state.totalWaste,
                        progressPercentage: state.progressPercentage,
                      ),
                      
                      // Monthly goal
                      RecyclingGoalCard(goal: state.monthlyGoal),
                      
                      // Quick actions section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Hành động nhanh',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      
                      // Quick action buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: QuickActionButton(
                                label: 'Quét rác',
                                icon: Icons.camera_alt,
                                onTap: () {
                                  // Navigate to waste scanning screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WasteDetectionScreen(),
                                    ),
                                  );
                                },
                                iconColor: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: QuickActionButton(
                                label: 'Đặt lịch',
                                icon: Icons.calendar_today,
                                onTap: () {
                                  // Navigate to schedule pickup screen
                                },
                                iconColor: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: QuickActionButton(
                                label: 'Tích điểm',
                                icon: Icons.stars,
                                onTap: () {
                                  // Navigate to points screen
                                },
                                iconColor: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Recent activities section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Hoạt động gần đây',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      
                      // Recent activities list
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: state.recentActivities
                              .map((activity) => RecentActivityItem(activity: activity))
                              .toList(),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            } else if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.errorRed,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải dữ liệu: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DashboardBloc>().add(const LoadDashboard(userId: userId));
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: 0,
          onTap: (index) {
            // Handle navigation to different screens
            // For now, just display a snackbar
            if (index != 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chuyển đến màn hình: $index'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
        ),
      ),
    );
  }
} 