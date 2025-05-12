import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/app_colors.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';
import '../models/user_profile.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/error_message.dart';
import 'package:intl/intl.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({Key? key}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load profile data when screen is initialized
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewProfileScreen(),
                ),
              ).then((_) {
                // Refresh profile data when returning from edit screen
                context.read<ProfileBloc>().add(LoadProfile());
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is ProfileError) {
            return ErrorMessage(
              message: state.message,
              onRetry: () => context.read<ProfileBloc>().add(LoadProfile()),
            );
          } else if (state is ProfileLoaded) {
            final userProfile = state.userProfile;
            return _buildProfileContent(userProfile);
          }
          return Center(
            child: TextButton(
              onPressed: () => context.read<ProfileBloc>().add(LoadProfile()),
              child: const Text('Tải thông tin'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(UserProfile userProfile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User basic info card
          _buildProfileHeader(userProfile.basicInfo),
          
          // Stats summary
          _buildTransactionStats(userProfile.transactionStats),
          
          // Tabs for detailed information
          _buildTabs(userProfile),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BasicInfo basicInfo) {
    final firstLetter = basicInfo.fullName.isNotEmpty ? basicInfo.fullName[0].toUpperCase() : '?';
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: AppColors.primaryGreen,
      child: Column(
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                firstLetter,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            basicInfo.fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            basicInfo.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            basicInfo.roles.isNotEmpty ? basicInfo.roles.join(', ') : 'Người dùng',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionStats(TransactionStats stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê giao dịch',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Tổng giao dịch', stats.totalTransactions.toString(), Icons.assignment),
              _buildStatItem('Đã hoàn thành', stats.completedTransactions, Icons.check_circle, color: Colors.green),
              _buildStatItem('Chờ xử lý', stats.pendingTransactions, Icons.hourglass_empty, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Xác nhận', stats.verifiedTransactions, Icons.verified, color: Colors.blue),
              _buildStatItem('Từ chối', stats.rejectedTransactions, Icons.cancel, color: Colors.red),
              _buildStatItem('Tổng khối lượng', '${stats.totalQuantity} kg', Icons.scale, color: AppColors.primaryGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, {Color color = Colors.grey}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(UserProfile userProfile) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryGreen,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: Colors.grey[600],
            tabs: const [
              Tab(text: 'Thông tin'),
              Tab(text: 'Thống kê'),
              Tab(text: 'Giao dịch'),
            ],
          ),
        ),
        SizedBox(
          height: 400, // Fixed height for tab content
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBasicInfoTab(userProfile.basicInfo, userProfile.accountStatus, userProfile.timezone),
              _buildStatsTab(userProfile.additionalData),
              _buildRecentTransactionsTab(userProfile.additionalData.latestTransactions),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoTab(BasicInfo basicInfo, AccountStatus accountStatus, String timezone) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin cơ bản',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Tên đầy đủ', basicInfo.fullName),
          _buildInfoRow('Tên đăng nhập', basicInfo.username),
          _buildInfoRow('Email', basicInfo.email),
          _buildInfoRow('Điện thoại', basicInfo.phone),
          _buildInfoRow('Địa chỉ', basicInfo.address),
          const Divider(height: 32),
          const Text(
            'Thông tin tài khoản',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Trạng thái', accountStatus.status),
          _buildInfoRow(
            'Ngày tạo',
            DateFormat('dd/MM/yyyy').format(DateTime.parse(accountStatus.createdAt)),
          ),
          _buildInfoRow('Múi giờ', timezone),
        ],
      ),
    );
  }

  Widget _buildStatsTab(AdditionalData additionalData) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loại rác thải đã thu gom',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: additionalData.wasteTypeStats.length,
            itemBuilder: (context, index) {
              final stat = additionalData.wasteTypeStats[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(stat.wasteTypeName),
                    Text(
                      '${stat.totalQuantity} kg',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 32),
          const Text(
            'Thông tin điểm thưởng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Tổng phần thưởng', additionalData.rewardStats.totalRewards.toString()),
          _buildInfoRow('Tổng điểm', additionalData.rewardStats.totalPoints),
          _buildInfoRow(
            'Ngày nhận thưởng gần nhất',
            DateFormat('dd/MM/yyyy').format(DateTime.parse(additionalData.rewardStats.lastRewardDate)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsTab(List<LatestTransaction> transactions) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giao dịch gần đây',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      transaction.wasteTypeName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${transaction.collectionPointName}\n${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(transaction.transactionDate))}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${transaction.quantity} kg',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        _buildStatusChip(transaction.status),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String displayText;
    
    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.green;
        displayText = 'Hoàn thành';
        break;
      case 'pending':
        chipColor = Colors.orange;
        displayText = 'Chờ xử lý';
        break;
      case 'verified':
        chipColor = Colors.blue;
        displayText = 'Xác nhận';
        break;
      case 'rejected':
        chipColor = Colors.red;
        displayText = 'Từ chối';
        break;
      default:
        chipColor = Colors.grey;
        displayText = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}