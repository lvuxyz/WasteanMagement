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
    });
  }

  void _onItemTapped(int index){
    // Navigation functionality would go here
    // For example: switch to a different screen based on index
    // Currently not implemented in the UI
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            const SizedBox(height: 24),
            _buildUserSummaryCard(),
            const SizedBox(height: 24),
            _buildRewardPointsCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Điểm thu gom'),
            const SizedBox(height: 16),
            _buildCollectionPointsList(),
            const SizedBox(height: 24),
            _buildSectionTitle('Loại rác được thu gom'),
            const SizedBox(height: 16),
            _buildWasteTypeList(),
            const SizedBox(height: 24),
            if (isAdmin) ...[
              _buildSectionTitle('Quản lý giao dịch'),
              const SizedBox(height: 16),
              _buildAllTransactionsList(),
            ] else ...[
              _buildSectionTitle('Giao dịch của bạn'),
              const SizedBox(height: 16),
              _buildMyTransactionsList(),
            ],
            const SizedBox(height: 16),
            _buildQuickActions(height: 16),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào,',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                String userName = 'Người dùng';
                if (state is ProfileLoaded) {
                  userName = state.userProfile.basicInfo.fullName;
                }
                return Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
          child: const Icon(
            Icons.person,
            color: AppColors.primaryGreen,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildUserSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.eco_outlined,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Tổng điểm thưởng', // Từ bảng Rewards.points
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '1,250', // Tổng Rewards.points của user
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '15.5 kg', // Tổng Transactions.quantity
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rác đã xử lý',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Đổi điểm',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              if (title == 'Quản lý giao dịch' || title == 'Giao dịch của bạn') {
                Navigator.pushNamed(context, '/transactions');
              } else if (title == 'Điểm thu gom gần bạn') {
                Navigator.pushNamed(context, '/collection-points');
              } else if (title == 'Loại rác được thu gom') {
                Navigator.pushNamed(context, '/waste-type');
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryGreen,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Thêm Quick Actions ở đây
  Widget _buildQuickActions({required double height}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Truy cập nhanh',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _buildQuickActionCard(
                icon: Icons.map,
                title: 'Bản đồ\nđiểm thu gom',
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, '/map');
                },
              ),
              _buildQuickActionCard(
                icon: Icons.recycling,
                title: 'Hướng dẫn\nphân loại',
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, '/waste-guide');
                },
              ),
              _buildQuickActionCard(
                icon: Icons.stars,
                title: 'Điểm thưởng\ncủa tôi',
                color: Colors.amber,
                onTap: () {
                  Navigator.pushNamed(context, '/rewards');
                },
              ),
              _buildQuickActionCard(
                icon: Icons.bar_chart,
                title: 'Thống kê\ntiến độ',
                color: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(context, '/recycling-progress');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionPointsList() {
    return FutureBuilder<List<CollectionPoint>>(
      future: context.read<CollectionPointRepository>().getAllCollectionPoints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 240,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        } else if (snapshot.hasError) {
          return Container(
            height: 240,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Lỗi: ${snapshot.error}',
              style: TextStyle(color: Colors.red[700]),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: 240,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Không có điểm thu gom nào.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final collectionPoints = snapshot.data!;
        
        return SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: collectionPoints.length,
            itemBuilder: (context, index) {
              final point = collectionPoints[index];
              final capacityPercentage = (point.currentLoad != null && point.capacity > 0) 
                  ? ((point.currentLoad! / point.capacity) * 100).clamp(0.0, 100.0).toInt() 
                  : 0;

              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
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
                        color: capacityPercentage > 80
                            ? Colors.red
                            : capacityPercentage > 50
                            ? Colors.orange
                            : Colors.green,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      point.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    margin: const EdgeInsets.only(left: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$capacityPercentage%',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: capacityPercentage > 80
                                            ? Colors.red
                                            : AppColors.primaryGreen,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppColors.textGrey,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    point.address,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: point.status.toLowerCase() == 'active'
                                        ? AppColors.primaryGreen.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    point.status.toLowerCase() == 'active' ? 'Mở cửa' : 'Đóng cửa',
                                    style: TextStyle(
                                      color: point.status.toLowerCase() == 'active'
                                          ? AppColors.primaryGreen
                                          : Colors.grey,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    point.operatingHours,
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 9,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: (point.currentLoad != null && point.capacity > 0) 
                                ? (point.currentLoad! / point.capacity).clamp(0.0, 1.0) 
                                : 0.0,
                              backgroundColor: Colors.grey[200],
                              minHeight: 3,
                              color: capacityPercentage > 80
                                  ? Colors.red
                                  : capacityPercentage > 50
                                  ? Colors.orange
                                  : AppColors.primaryGreen,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Công suất:',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${point.currentLoad?.toStringAsFixed(1) ?? "0"}/${point.capacity} kg',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
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
              height: 130,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          } else if (state is WasteTypeError) {
            return Container(
              height: 130,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Lỗi: ${state.message}',
                style: TextStyle(color: Colors.red[700]),
              ),
            );
          } else if (state is WasteTypeLoaded) {
            final wasteTypes = state.wasteTypes;
            
            if (wasteTypes.isEmpty) {
              return Container(
                height: 130,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Không có loại rác nào.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            
            return SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: wasteTypes.length,
                itemBuilder: (context, index) {
                  final wasteType = wasteTypes[index];
                  
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: wasteType.color.withOpacity(0.2),
                            child: Icon(
                              wasteType.icon,
                              color: wasteType.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              wasteType.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
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
            height: 130,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          color: AppColors.primaryGreen,
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
                          'Chưa có giao dịch nào được tạo trong hệ thống',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.transactions.length > 3 ? 3 : state.transactions.length, // Limit to 3 items
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey[200],
                      ),
                      itemBuilder: (context, index) {
                        final transaction = state.transactions[index];
                        final IconData icon = _getWasteTypeIcon(transaction.wasteTypeName);
                        final Color iconColor = _getWasteTypeColor(transaction.wasteTypeName);
                        final DateFormat formatter = DateFormat('dd/MM/yyyy');

                        return InkWell(
                          onTap: () {
                            // Navigate to full transactions screen when clicking on a transaction
                            Navigator.pushNamed(context, '/transactions');
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                color: iconColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              '${transaction.quantity} ${transaction.unit} ${transaction.wasteTypeName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.collectionPointName,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  formatter.format(transaction.transactionDate),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            trailing: Container(
                              constraints: const BoxConstraints(maxWidth: 80),
                              child: transaction.status == 'completed'
                                  ? const Text(
                                '+12',  // Replace with actual points when available in API
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )
                                  : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(transaction.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
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
                            ),
                          ),
                        );
                      },
                    ),
                    if (state.hasReachedMax == false || state.totalPages > 1)
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/transactions');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
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
        )..add(FetchMyTransactions(limit: 3)); // Use the correct event for user's transactions
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.primaryGreen,
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
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.transactions.length > 3 ? 3 : state.transactions.length, // Limit to 3 items
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final transaction = state.transactions[index];
                    final IconData icon = _getWasteTypeIcon(transaction.wasteTypeName);
                    final Color iconColor = _getWasteTypeColor(transaction.wasteTypeName);
                    final DateFormat formatter = DateFormat('dd/MM/yyyy');

                    return InkWell(
                      onTap: () {
                        // Điều hướng đến màn hình giao dịch đầy đủ khi nhấp vào giao dịch
                        Navigator.pushNamed(context, '/transactions');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                icon,
                                color: iconColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                  Text(
                                    formatter.format(transaction.transactionDate),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            transaction.status == 'completed'
                                ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.eco_outlined,
                                    color: AppColors.primaryGreen,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '+12',  // Thay thế bằng điểm thực tế khi có sẵn
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
                                color: _getStatusColor(transaction.status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
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
                  },
                ),
                if (state.hasReachedMax == false || state.totalPages > 1)
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/transactions');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
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

  Widget _buildCollectionPointsPage() {
    return const Center(
      child: Text('Trang Điểm Thu Gom'),
    );
  }

  Widget _buildStatisticsPage() {
    return const Center(
      child: Text('Trang Thống Kê'),
    );
  }

  Widget _buildProfilePage() {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfile()),
      child: const ProfileScreen(username: '',),
    );
  }

  Widget _buildCustomNavigationBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Regular navigation items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_outlined, 0),
              _buildNavItem(Icons.location_on_outlined, 1),
              // Empty space for the center button
              const SizedBox(width: 65),
              _buildNavItem(Icons.bar_chart_outlined, 3),
              _buildNavItem(Icons.person_outline, 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      onPressed: () => _onItemTapped(index),
      icon: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      padding: const EdgeInsets.all(8),
      highlightColor: Colors.white24,
      splashColor: Colors.white24,
    );
  }

  // Add reward points card
  Widget _buildRewardPointsCard() {
    return BlocBuilder<RewardBloc, RewardState>(
      builder: (context, state) {
        int totalPoints = 0;
        bool isLoading = state is RewardLoading;
        
        if (state is MyRewardsLoaded) {
          totalPoints = state.totalPoints;
        } else if (!(state is RewardLoading)) {
          // Nếu chưa load dữ liệu thì load
          context.read<RewardBloc>().add(LoadMyRewards(page: 1));
        }
        
        return InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.rewards);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.stars,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Điểm thưởng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        '$totalPoints',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const SizedBox(height: 8),
                const Text(
                  'Tham gia các hoạt động để tích lũy điểm thưởng',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}