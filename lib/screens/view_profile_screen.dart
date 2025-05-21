import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:http/http.dart' as http;
import '../core/api/api_constants.dart';
import '../services/auth_service.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/error_message.dart';
import 'package:intl/intl.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({Key? key}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không tìm thấy token xác thực';
        });
        return;
      }
      
      // Make API request
      final response = await http.get(
        Uri.parse(ApiConstants.profile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print("[DEBUG] Status code: ${response.statusCode}");
      print("[DEBUG] Response body: ${response.body.substring(0, 100)}...");
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            _userData = responseData['data'];
            _isLoading = false;
          });
          
          print("[DEBUG] User data loaded: ${_userData['basic_info']?['full_name']}");
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Không thể tải thông tin người dùng';
          });
        }
      } else {
        // Error handling
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi khi tải thông tin người dùng: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      print("[DEBUG] Error loading profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('Thông tin cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: _isLoading 
          ? const Center(child: LoadingIndicator())
          : _errorMessage.isNotEmpty
            ? ErrorMessage(
                message: _errorMessage,
                onRetry: _loadUserData,
              )
            : _buildProfileContent(),
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_userData.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu người dùng'),
      );
    }

    final basicInfo = _userData['basic_info'] ?? {};
    final transactionStats = _userData['transaction_stats'] ?? {};
    final accountStatus = _userData['account_status'] ?? {};
    final additionalData = _userData['additional_data'] ?? {};
    
    print("[DEBUG] Building UI with basic info: $basicInfo");
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar and basic info
          _buildProfileHeader(basicInfo),
          
          const SizedBox(height: 24),
          
          // Transaction stats card
          _buildStatsCard(transactionStats),
          
          const SizedBox(height: 24),
          
          // Account info card
          _buildAccountInfoCard(basicInfo, accountStatus, additionalData),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> basicInfo) {
    final fullName = basicInfo['full_name'] ?? '';
    final email = basicInfo['email'] ?? '';
    final phone = basicInfo['phone'] ?? '';
    final roles = (basicInfo['roles'] as List?)?.cast<String>() ?? <String>[];
    
    final firstLetter = fullName.isNotEmpty 
        ? fullName[0].toUpperCase() 
        : '?';
        
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
              child: Text(
                firstLetter,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  if (roles.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        roles.join(', '),
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    final totalTransactions = stats['total_transactions']?.toString() ?? '0';
    final completedTransactions = stats['completed_transactions']?.toString() ?? '0';
    final pendingTransactions = stats['pending_transactions']?.toString() ?? '0';
    final rejectedTransactions = stats['rejected_transactions']?.toString() ?? '0';
    final verifiedTransactions = stats['verified_transactions']?.toString() ?? '0';
    final totalQuantity = stats['total_quantity']?.toString() ?? '0';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  'Tổng giao dịch',
                  totalTransactions,
                  Icons.assignment,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Hoàn thành',
                  completedTransactions,
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  'Chờ xử lý',
                  pendingTransactions,
                  Icons.hourglass_empty,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  'Từ chối',
                  rejectedTransactions,
                  Icons.cancel,
                  Colors.red,
                ),
                _buildStatItem(
                  'Đã xác nhận',
                  verifiedTransactions,
                  Icons.verified,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Tổng KL',
                  '$totalQuantity kg',
                  Icons.scale,
                  AppColors.primaryGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(
    Map<String, dynamic> basicInfo,
    Map<String, dynamic> accountStatus,
    Map<String, dynamic> additionalData,
  ) {
    final rewardStats = additionalData['reward_stats'] ?? {};
    final timezone = _userData['timezone'] ?? 'UTC';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin tài khoản',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Tên đăng nhập', basicInfo['username'] ?? ''),
            _buildInfoRow('Địa chỉ', basicInfo['address'] ?? ''),
            _buildInfoRow('Trạng thái', _getStatusText(accountStatus['status'] ?? '')),
            _buildInfoRow('Ngày tạo', _formatDateTime(accountStatus['created_at'] ?? '')),
            _buildInfoRow('Múi giờ', timezone),
            
            const SizedBox(height: 16),
            const Text(
              'Thông tin điểm thưởng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Tổng phần thưởng', 
              (rewardStats['total_rewards'] ?? 0).toString(),
              valueColor: Colors.green,
            ),
            _buildInfoRow(
              'Tổng điểm', 
              _formatNumber(rewardStats['total_points']?.toString() ?? '0'),
              valueColor: Colors.blue,
            ),
            _buildInfoRow(
              'Ngày nhận thưởng gần nhất',
              _formatDateTime(rewardStats['last_reward_date'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label, 
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
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