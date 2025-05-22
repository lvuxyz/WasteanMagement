import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/blocs/profile/profile_bloc.dart';
import 'package:wasteanmagement/blocs/profile/profile_event.dart';
import 'package:wasteanmagement/blocs/profile/profile_state.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_bloc.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_event.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_state.dart';
import 'package:wasteanmagement/blocs/waste_type/waste_type_bloc.dart';
import 'package:wasteanmagement/blocs/waste_type/waste_type_event.dart';
import 'package:wasteanmagement/blocs/waste_type/waste_type_state.dart';
import 'package:wasteanmagement/core/api/api_client.dart';
import 'package:wasteanmagement/models/collection_point.dart';
import 'package:wasteanmagement/repositories/collection_point_repository.dart';
import 'package:wasteanmagement/repositories/transaction_repository.dart';
import 'package:wasteanmagement/repositories/waste_type_repository.dart';
import 'package:wasteanmagement/routes.dart';
import 'package:wasteanmagement/screens/profile_screen.dart';
import 'package:wasteanmagement/services/auth_service.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import 'package:wasteanmagement/blocs/reward/reward_bloc.dart';
import 'package:wasteanmagement/blocs/reward/reward_event.dart';
import 'package:wasteanmagement/blocs/reward/reward_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();

    // Ensure profile data is loaded
    Future.microtask(() {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is! ProfileLoaded) {
        context.read<ProfileBloc>().add(LoadProfile());
      }

      // Ensure waste type data is loaded
      final wasteTypeBloc = context.read<WasteTypeBloc>();
      if (wasteTypeBloc.state is! WasteTypeLoaded) {
        wasteTypeBloc.add(LoadWasteTypes());
      }

      // Load reward data
      context.read<RewardBloc>().add(LoadMyRewards(page: 1));
    });
  }

  void _onItemTapped(int index){
    // Navigation functionality would go here
    // For example: switch to a different screen based on index
    // Currently not implemented in the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
          future: _authService.isAdmin(),
          builder: (context, snapshot) {
            final isAdmin = snapshot.data ?? false;

            if (snapshot.connectionState == ConnectionState.waiting) {
              // Still loading admin status, show loading indicator
              return const Center(child: CircularProgressIndicator());
            }

            // Admin status is now available
            print('Home screen - User is admin: $isAdmin');
            return _buildHomePage(isAdmin);
          }
      ),
    );
  }

  Widget _buildHomePage(bool isAdmin) {
    return SafeArea(
      top: true,
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<ProfileBloc>().add(LoadProfile());
          context.read<WasteTypeBloc>().add(LoadWasteTypes());
          context.read<RewardBloc>().add(LoadMyRewards(page: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với gradient background
              _buildHeader(),

              // Main content với padding
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unified summary card (gộp điểm thưởng và thông tin user)
                    _buildUnifiedSummaryCard(),
                    const SizedBox(height: 24),

                    // Quick Actions Grid
                    _buildQuickActionsGrid(),
                    const SizedBox(height: 24),

                    // Collection Points Section
                    _buildSectionHeader('Điểm thu gom', '/collection-points'),
                    const SizedBox(height: 12),
                    _buildCollectionPointsList(),
                    const SizedBox(height: 24),

                    // Waste Types Section
                    _buildSectionHeader('Loại rác được thu gom', '/waste-type'),
                    const SizedBox(height: 12),
                    _buildWasteTypeList(),
                    const SizedBox(height: 24),

                    // Transactions Section
                    isAdmin
                        ? _buildSectionHeader('Quản lý giao dịch', '/transactions')
                        : _buildSectionHeader('Giao dịch gần đây', '/transactions'),
                    const SizedBox(height: 12),
                    isAdmin ? _buildAllTransactionsList() : _buildMyTransactionsList(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào,',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      String userName = 'Người dùng';
                      if (state is ProfileLoaded) {
                        userName = state.userProfile.basicInfo.fullName;
                      }
                      return Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy cùng bảo vệ môi trường xanh!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedSummaryCard() {
    return BlocBuilder<RewardBloc, RewardState>(
      builder: (context, rewardState) {
        int totalPoints = 0;
        bool isLoadingRewards = rewardState is RewardLoading;

        if (rewardState is MyRewardsLoaded) {
          totalPoints = rewardState.totalPoints;
        }

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4CAF50),
                Color(0xFF66BB6A),
                Color(0xFF43A047),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.stars,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Điểm thưởng',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          isLoadingRewards
                              ? const SizedBox(
                            height: 40,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                              : Text(
                            '$totalPoints',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.eco_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '15.5 kg',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rác đã xử lý',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.rewards);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryGreen,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.redeem, size: 20),
                        label: const Text(
                          'Đổi điểm',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/recycling-progress');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.trending_up, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {
        'icon': Icons.map_outlined,
        'title': 'Bản đồ',
        'subtitle': 'Điểm thu gom',
        'color': Colors.blue,
        'route': '/map',
      },
      {
        'icon': Icons.recycling_outlined,
        'title': 'Hướng dẫn',
        'subtitle': 'Phân loại rác',
        'color': Colors.green,
        'route': '/waste-guide',
      },
      {
        'icon': Icons.history_outlined,
        'title': 'Lịch sử',
        'subtitle': 'Giao dịch',
        'color': Colors.orange,
        'route': '/transactions',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Truy cập nhanh',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildQuickActionCard(
              icon: action['icon'] as IconData,
              title: action['title'] as String,
              subtitle: action['subtitle'] as String,
              color: action['color'] as Color,
              onTap: () {
                Navigator.pushNamed(context, action['route'] as String);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, route);
          },
          icon: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.primaryGreen,
          ),
          label: const Text(
            'Xem tất cả',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionPointsList() {
    return FutureBuilder<List<CollectionPoint>>(
      future: context.read<CollectionPointRepository>().getAllCollectionPoints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        } else if (snapshot.hasError) {
          return Container(
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Không thể tải dữ liệu',
              style: TextStyle(color: Colors.red[700]),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Không có điểm thu gom nào',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final collectionPoints = snapshot.data!;

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: collectionPoints.length,
            itemBuilder: (context, index) {
              final point = collectionPoints[index];
              final capacityPercentage = (point.currentLoad != null && point.capacity > 0)
                  ? ((point.currentLoad! / point.capacity) * 100).clamp(0.0, 100.0).toInt()
                  : 0;

              return Container(
                width: 260,
                margin: EdgeInsets.only(
                  right: index == collectionPoints.length - 1 ? 0 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getCapacityColor(capacityPercentage),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: Text(
                                    point.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCapacityColor(capacityPercentage).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$capacityPercentage%',
                                    style: TextStyle(
                                      color: _getCapacityColor(capacityPercentage),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.grey[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    point.address,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: point.status.toLowerCase() == 'active'
                                          ? AppColors.primaryGreen.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      point.status.toLowerCase() == 'active' ? 'Mở cửa' : 'Đóng cửa',
                                      style: TextStyle(
                                        color: point.status.toLowerCase() == 'active'
                                            ? AppColors.primaryGreen
                                            : Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    point.operatingHours,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.end,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Công suất',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '${point.currentLoad?.toStringAsFixed(1) ?? "0"}/${point.capacity} kg',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: (point.currentLoad != null && point.capacity > 0)
                                      ? (point.currentLoad! / point.capacity).clamp(0.0, 1.0)
                                      : 0.0,
                                  backgroundColor: Colors.grey[200],
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                  color: _getCapacityColor(capacityPercentage),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getCapacityColor(int percentage) {
    if (percentage > 80) return Colors.red;
    if (percentage > 50) return Colors.orange;
    return AppColors.primaryGreen;
  }

  Widget _buildWasteTypeList() {
    return BlocProvider(
      create: (context) {
        final repository = context.read<WasteTypeRepository>();
        return WasteTypeBloc(repository: repository)..add(LoadWasteTypes());
      },
      child: BlocBuilder<WasteTypeBloc, WasteTypeState>(
        builder: (context, state) {
          if (state is WasteTypeLoading) {
            return Container(
              height: 120,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          } else if (state is WasteTypeError) {
            return Container(
              height: 120,
              alignment: Alignment.center,
              child: Text(
                'Không thể tải dữ liệu',
                style: TextStyle(color: Colors.red[700]),
              ),
            );
          } else if (state is WasteTypeLoaded) {
            final wasteTypes = state.wasteTypes;

            if (wasteTypes.isEmpty) {
              return Container(
                height: 120,
                alignment: Alignment.center,
                child: const Text(
                  'Không có loại rác nào',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: wasteTypes.length,
                itemBuilder: (context, index) {
                  final wasteType = wasteTypes[index];

                  return Container(
                    width: 140,
                    margin: EdgeInsets.only(
                      right: index == wasteTypes.length - 1 ? 0 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: wasteType.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              wasteType.icon,
                              color: wasteType.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            wasteType.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${wasteType.unitPrice.toStringAsFixed(0)} đ/${wasteType.unit}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return Container(
            height: 120,
            alignment: Alignment.center,
            child: const Text('Đang tải dữ liệu...'),
          );
        },
      ),
    );
  }

  Widget _buildAllTransactionsList() {
    return FutureBuilder<bool>(
      future: _authService.isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isAdmin = snapshot.data ?? false;
        if (!isAdmin) {
          print('Regular user, but trying to build admin transaction list');
        }

        return BlocProvider(
          create: (context) {
            final apiClient = context.read<ApiClient>();
            final transactionRepository = TransactionRepository(apiClient: apiClient);

            print('Building all transactions list for admin. Admin status: $isAdmin');
            return TransactionBloc(
              transactionRepository: transactionRepository,
            )..add(FetchTransactions(limit: 3)); // Reduced limit to 3 for home screen
          },
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state.status == TransactionStatus.initial ||
                  state.status == TransactionStatus.loading && state.transactions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state.status == TransactionStatus.failure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Không thể tải danh sách giao dịch',
                          style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                        ),
                        if (state.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              state.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[700], fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            print('Retrying all transactions fetch');
                            context.read<TransactionBloc>().add(RefreshTransactions());
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state.transactions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Không có giao dịch nào',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Chưa có giao dịch nào được tạo',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.transactions.length > 3 ? 3 : state.transactions.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey[200],
                      ),
                      itemBuilder: (context, index) {
                        final transaction = state.transactions[index];
                        final IconData icon = _getWasteTypeIcon(transaction.wasteTypeName);
                        final Color iconColor = _getWasteTypeColor(transaction.wasteTypeName);
                        final DateFormat formatter = DateFormat('dd/MM/yyyy');

                        return _buildTransactionItem(
                          transaction: transaction,
                          icon: icon,
                          iconColor: iconColor,
                          formatter: formatter,
                        );
                      },
                    ),
                    if (state.hasReachedMax == false || state.totalPages > 1)
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/transactions');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Xem tất cả giao dịch',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMyTransactionsList() {
    return BlocProvider(
      create: (context) {
        final apiClient = context.read<ApiClient>();
        final transactionRepository = TransactionRepository(apiClient: apiClient);

        return TransactionBloc(
          transactionRepository: transactionRepository,
        )..add(FetchMyTransactions(limit: 3));
      },
      child: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state.status == TransactionStatus.initial ||
              state.status == TransactionStatus.loading && state.transactions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state.status == TransactionStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Không thể tải danh sách giao dịch',
                      style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                    ),
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<TransactionBloc>().add(RefreshTransactions());
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state.transactions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.grey[400],
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Không có giao dịch nào',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bạn chưa thực hiện giao dịch nào',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.transactions.length > 3 ? 3 : state.transactions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final transaction = state.transactions[index];
                    final IconData icon = _getWasteTypeIcon(transaction.wasteTypeName);
                    final Color iconColor = _getWasteTypeColor(transaction.wasteTypeName);
                    final DateFormat formatter = DateFormat('dd/MM/yyyy');

                    return _buildTransactionItem(
                      transaction: transaction,
                      icon: icon,
                      iconColor: iconColor,
                      formatter: formatter,
                    );
                  },
                ),
                if (state.hasReachedMax == false || state.totalPages > 1)
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/transactions');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Xem tất cả giao dịch',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem({
    required dynamic transaction,
    required IconData icon,
    required Color iconColor,
    required DateFormat formatter,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/transactions');
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${transaction.quantity} ${transaction.unit} ${transaction.wasteTypeName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.collectionPointName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatter.format(transaction.transactionDate),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            transaction.status == 'completed'
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco_outlined,
                    color: AppColors.primaryGreen,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '+12',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getStatusText(transaction.status),
                style: TextStyle(
                  color: _getStatusColor(transaction.status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWasteTypeIcon(String wasteType) {
    if (wasteType.toLowerCase().contains('plastic')) {
      return Icons.delete_outline;
    } else if (wasteType.toLowerCase().contains('paper') ||
        wasteType.toLowerCase().contains('cardboard')) {
      return Icons.description_outlined;
    } else if (wasteType.toLowerCase().contains('electronic')) {
      return Icons.devices_outlined;
    } else if (wasteType.toLowerCase().contains('metal')) {
      return Icons.settings_outlined;
    } else if (wasteType.toLowerCase().contains('glass')) {
      return Icons.local_drink_outlined;
    } else {
      return Icons.delete_outline;
    }
  }

  Color _getWasteTypeColor(String wasteType) {
    if (wasteType.toLowerCase().contains('plastic')) {
      return Colors.blue;
    } else if (wasteType.toLowerCase().contains('paper') ||
        wasteType.toLowerCase().contains('cardboard')) {
      return Colors.amber;
    } else if (wasteType.toLowerCase().contains('electronic')) {
      return Colors.purple;
    } else if (wasteType.toLowerCase().contains('metal')) {
      return Colors.blueGrey;
    } else if (wasteType.toLowerCase().contains('glass')) {
      return Colors.teal;
    } else {
      return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Hoàn thành';
      case 'pending':
        return 'Chờ xử lý';
      case 'processing':
        return 'Đang xử lý';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }
}