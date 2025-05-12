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
      backgroundColor: Colors.grey.shade100,
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
              Navigator.pushNamed(context, '/edit-profile').then((_) {
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
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(LoadProfile());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user information
            _buildProfileHeader(userProfile.basicInfo),
            
            // Cards with summary statistics
            _buildStatisticsCards(userProfile.transactionStats),
            
            // Tabs for detailed information
            _buildDetailTabs(userProfile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BasicInfo basicInfo) {
    final firstLetter = basicInfo.fullName.isNotEmpty ? basicInfo.fullName[0].toUpperCase() : '?';
    
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                firstLetter,
                style: TextStyle(
                  fontSize: 45,
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 16, color: Colors.white70),
              const SizedBox(width: 5),
              Text(
                basicInfo.email,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.white70),
              const SizedBox(width: 5),
              Text(
                basicInfo.phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user, size: 14, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  basicInfo.roles.isNotEmpty ? basicInfo.roles.join(', ') : 'Người dùng',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(TransactionStats stats) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Thống kê tổng quan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        'Tổng giao dịch',
                        stats.totalTransactions.toString(),
                        Icons.assignment,
                        Colors.blue,
                      ),
                      _buildStatColumn(
                        'Đã hoàn thành',
                        stats.completedTransactions,
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatColumn(
                        'Chờ xử lý',
                        stats.pendingTransactions,
                        Icons.hourglass_empty,
                        Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        'Đã xác nhận',
                        stats.verifiedTransactions,
                        Icons.verified,
                        Colors.blue,
                      ),
                      _buildStatColumn(
                        'Từ chối',
                        stats.rejectedTransactions,
                        Icons.cancel,
                        Colors.red,
                      ),
                      _buildStatColumn(
                        'Tổng khối lượng',
                        '${stats.totalQuantity} kg',
                        Icons.scale,
                        AppColors.primaryGreen,
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
  }

  Widget _buildStatColumn(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
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

  Widget _buildDetailTabs(UserProfile userProfile) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.primaryGreen,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[700],
            tabs: const [
              Tab(
                icon: Icon(Icons.person_outline),
                text: 'Thông tin',
              ),
              Tab(
                icon: Icon(Icons.bar_chart),
                text: 'Thống kê',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Giao dịch',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Tab content
        SizedBox(
          height: 450, // Adjust height as needed
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(userProfile),
              _buildStatsTab(userProfile),
              _buildTransactionsTab(userProfile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTab(UserProfile userProfile) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Thông tin cơ bản', Icons.person),
              const SizedBox(height: 10),
              _buildInfoRow('Tên đầy đủ', userProfile.basicInfo.fullName),
              _buildInfoRow('Tên đăng nhập', userProfile.basicInfo.username),
              _buildInfoRow('Email', userProfile.basicInfo.email),
              _buildInfoRow('Điện thoại', userProfile.basicInfo.phone),
              _buildInfoRow('Địa chỉ', userProfile.basicInfo.address),
              
              const SizedBox(height: 20),
              _buildSectionHeader('Thông tin tài khoản', Icons.security),
              const SizedBox(height: 10),
              _buildInfoRow('Trạng thái', _getStatusText(userProfile.accountStatus.status)),
              _buildInfoRow('Ngày tạo', _formatDateTime(userProfile.accountStatus.createdAt)),
              _buildInfoRow('Múi giờ', userProfile.timezone),
              _buildInfoRow('Số lần đăng nhập sai', userProfile.accountStatus.loginAttempts.toString()),
              
              if (userProfile.accountStatus.lockUntil != null)
                _buildInfoRow('Khóa đến', _formatDateTime(userProfile.accountStatus.lockUntil!)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsTab(UserProfile userProfile) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Loại rác thải đã thu gom', Icons.delete_outline),
              const SizedBox(height: 10),
              ...userProfile.additionalData.wasteTypeStats.map((stat) => 
                _buildWasteTypeRow(stat.wasteTypeName, stat.totalQuantity)
              ).toList(),
              
              const SizedBox(height: 20),
              _buildSectionHeader('Thông tin điểm thưởng', Icons.card_giftcard),
              const SizedBox(height: 10),
              _buildInfoRow(
                'Tổng phần thưởng', 
                userProfile.additionalData.rewardStats.totalRewards.toString(),
                valueColor: Colors.green,
                valueBold: true,
              ),
              _buildInfoRow(
                'Tổng điểm', 
                _formatNumber(userProfile.additionalData.rewardStats.totalPoints),
                valueColor: Colors.blue,
                valueBold: true,
              ),
              _buildInfoRow(
                'Ngày nhận thưởng gần nhất',
                _formatDateTime(userProfile.additionalData.rewardStats.lastRewardDate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsTab(UserProfile userProfile) {
    final transactions = userProfile.additionalData.latestTransactions;
    
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'Không có giao dịch gần đây',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Giao dịch gần đây', Icons.history),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionItem(transaction);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(LatestTransaction transaction) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _getTransactionIcon(transaction.status),
      title: Text(
        transaction.wasteTypeName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(transaction.collectionPointName),
          Text(
            _formatDateTime(transaction.transactionDate, includeTime: true),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${transaction.quantity} kg',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _buildStatusChip(transaction.status),
        ],
      ),
    );
  }

  Widget _getTransactionIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
        );
      case 'pending':
        return CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1),
          child: const Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
        );
      case 'verified':
        return CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.verified, color: Colors.blue, size: 20),
        );
      case 'rejected':
        return CircleAvatar(
          backgroundColor: Colors.red.withOpacity(0.1),
          child: const Icon(Icons.cancel, color: Colors.red, size: 20),
        );
      default:
        return CircleAvatar(
          backgroundColor: Colors.grey.withOpacity(0.1),
          child: const Icon(Icons.help_outline, color: Colors.grey, size: 20),
        );
    }
  }

  Widget _buildWasteTypeRow(String wasteType, String quantity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(wasteType)),
          Text(
            '$quantity kg',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label, 
    String value, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              style: TextStyle(
                fontSize: 15,
                color: valueColor,
                fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.5))
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: chipColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeStr, {bool includeTime = false}) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      if (includeTime) {
        return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
      }
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Hoạt động';
      case 'inactive':
        return 'Không hoạt động';
      case 'suspended':
        return 'Tạm khóa';
      case 'locked':
        return 'Đã khóa';
      default:
        return status;
    }
  }
  
  String _formatNumber(String number) {
    try {
      final num = int.parse(number);
      final format = NumberFormat('#,###');
      return format.format(num);
    } catch (e) {
      return number;
    }
  }
}