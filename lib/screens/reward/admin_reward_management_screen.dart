import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/blocs/reward/reward_bloc.dart';
import 'package:wasteanmagement/blocs/reward/reward_event.dart';
import 'package:wasteanmagement/blocs/reward/reward_state.dart';
import 'package:wasteanmagement/models/reward.dart';
import 'package:wasteanmagement/services/auth_service.dart';
import 'package:wasteanmagement/utils/app_colors.dart';
import 'package:wasteanmagement/widgets/common/loading_indicator.dart';
import 'package:wasteanmagement/widgets/common/error_view.dart';
import 'package:intl/intl.dart';

class AdminRewardManagementScreen extends StatefulWidget {
  const AdminRewardManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminRewardManagementScreen> createState() => _AdminRewardManagementScreenState();
}

class _AdminRewardManagementScreenState extends State<AdminRewardManagementScreen> {
  final _searchController = TextEditingController();
  int? _selectedUserId;
  String? _selectedUserName;
  List<Map<String, dynamic>> _usersList = [];
  bool _isLoadingUsers = false;
  bool _isAdmin = false;
  final AuthService _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }
  
  Future<void> _checkAdminStatus() async {
    final isAdmin = await _authService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
    
    if (!isAdmin) {
      // Show unauthorized message
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn không có quyền truy cập chức năng này'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      });
    }
  }
  
  void _loadUserRewards() {
    if (_selectedUserId != null) {
      context.read<RewardBloc>().add(LoadUserRewards(userId: _selectedUserId!));
    }
  }
  
  void _showUserSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Chọn người dùng'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm người dùng...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // In a real app, this would trigger a search API call
                      // For now, we'll simulate it
                      _searchUsers(value, setState);
                    },
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingUsers)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    )
                  else if (_usersList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Không tìm thấy người dùng'),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _usersList.length,
                        itemBuilder: (context, index) {
                          final user = _usersList[index];
                          return ListTile(
                            title: Text(user['name'] ?? 'Người dùng ${user['id']}'),
                            subtitle: Text(user['email'] ?? ''),
                            onTap: () {
                              setState(() {
                                _selectedUserId = user['id'];
                                _selectedUserName = user['name'] ?? 'Người dùng ${user['id']}';
                              });
                              Navigator.pop(context);
                              
                              // Load the selected user's rewards
                              _loadUserRewards();
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  // Simulate searching users - in a real app, this would call an API
  void _searchUsers(String query, Function setState) {
    setState(() {
      _isLoadingUsers = true;
    });
    
    // Simulate API delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoadingUsers = false;
        
        // Mock user data for demonstration
        _usersList = [
          {'id': 1, 'name': 'Nguyễn Văn A', 'email': 'nguyenvana@example.com'},
          {'id': 2, 'name': 'Trần Thị B', 'email': 'tranthib@example.com'},
          {'id': 3, 'name': 'Lê Văn C', 'email': 'levanc@example.com'},
          {'id': 4, 'name': 'Phạm Thị D', 'email': 'phamthid@example.com'},
          {'id': 5, 'name': 'Hoàng Văn E', 'email': 'hoangvane@example.com'},
        ].where((user) {
          final name = user['name']?.toString().toLowerCase() ?? '';
          final email = user['email']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || email.contains(searchLower);
        }).toList();
      });
    });
  }
  
  void _showAddRewardDialog() {
    if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn người dùng trước'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final pointsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm điểm thưởng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Người dùng: $_selectedUserName'),
            const SizedBox(height: 16),
            TextField(
              controller: pointsController,
              decoration: const InputDecoration(
                labelText: 'Số điểm',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            onPressed: () {
              try {
                final points = int.parse(pointsController.text);
                
                // Add reward points
                context.read<RewardBloc>().add(CreateReward(
                  userId: _selectedUserId!,
                  points: points,
                ));
                
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thêm điểm thưởng thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Reload user rewards
                _loadUserRewards();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Quản lý điểm thưởng',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildUserSelectionBar(),
          Expanded(
            child: _selectedUserId == null
                ? _buildSelectUserPrompt()
                : BlocConsumer<RewardBloc, RewardState>(
                    listener: (context, state) {
                      if (state is RewardCreated || state is RewardUpdated || state is RewardDeleted) {
                        // Reload user rewards after successful operations
                        _loadUserRewards();
                      }
                    },
                    builder: (context, state) {
                      if (state is RewardLoading) {
                        return const Center(child: LoadingIndicator());
                      } else if (state is UserRewardsLoaded && state.userId == _selectedUserId) {
                        return _buildUserRewardsList(state);
                      } else if (state is RewardError) {
                        return ErrorView(
                          message: state.message,
                          onRetry: _loadUserRewards,
                          title: 'Lỗi tải dữ liệu',
                        );
                      }
                      
                      // Initial state or unexpected state
                      return const Center(child: LoadingIndicator());
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _selectedUserId != null
          ? FloatingActionButton(
              onPressed: _showAddRewardDialog,
              backgroundColor: AppColors.primaryGreen,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildUserSelectionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _showUserSelectionDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      _selectedUserName ?? 'Chọn người dùng',
                      style: TextStyle(
                        color: _selectedUserName != null
                            ? Colors.black
                            : Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
          if (_selectedUserId != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadUserRewards,
              tooltip: 'Làm mới',
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSelectUserPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Chọn người dùng để quản lý điểm thưởng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showUserSelectionDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('Chọn người dùng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserRewardsList(UserRewardsLoaded state) {
    if (state.rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stars_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Người dùng $_selectedUserName chưa có điểm thưởng',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm điểm thưởng bằng nút + bên dưới',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.rewards.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final reward = state.rewards[index];
        return _buildRewardItem(reward);
      },
    );
  }
  
  Widget _buildRewardItem(Reward reward) {
    final formatter = DateFormat('dd/MM/yyyy');
    final bool isPositive = reward.points > 0;
    
    return Dismissible(
      key: Key('reward_${reward.rewardId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa điểm thưởng này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        // Delete reward
        context.read<RewardBloc>().add(DeleteReward(reward.rewardId));
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa điểm thưởng'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPositive 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.add_circle : Icons.remove_circle,
              color: isPositive ? Colors.green : Colors.red,
              size: 28,
            ),
          ),
          title: Text(
            reward.source,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Ngày: ${formatter.format(reward.earnedDate)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (reward.transactionId != null)
                Text(
                  'Mã giao dịch: ${reward.transactionId}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isPositive ? '+' : ''}${reward.points}',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditRewardDialog(reward),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showEditRewardDialog(Reward reward) {
    final pointsController = TextEditingController(text: reward.points.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa điểm thưởng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã: ${reward.rewardId}'),
            const SizedBox(height: 8),
            Text('Nguồn: ${reward.source}'),
            const SizedBox(height: 16),
            TextField(
              controller: pointsController,
              decoration: const InputDecoration(
                labelText: 'Số điểm',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            onPressed: () {
              try {
                final points = int.parse(pointsController.text);
                
                // Update reward points
                context.read<RewardBloc>().add(UpdateReward(
                  rewardId: reward.rewardId,
                  points: points,
                ));
                
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cập nhật điểm thưởng thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 