import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wasteanmagement/blocs/reward/reward_bloc.dart';
import 'package:wasteanmagement/blocs/reward/reward_event.dart';
import 'package:wasteanmagement/blocs/reward/reward_state.dart';
import 'package:wasteanmagement/models/reward.dart';
import 'package:wasteanmagement/screens/reward/reward_statistics_screen.dart';
import 'package:wasteanmagement/screens/reward/reward_rankings_screen.dart';
import 'package:wasteanmagement/utils/app_colors.dart';
import 'package:wasteanmagement/widgets/common/loading_indicator.dart';
import 'package:wasteanmagement/widgets/common/error_view.dart';

class RewardScreen extends StatefulWidget {
  final bool isInTabView;
  
  const RewardScreen({Key? key, this.isInTabView = true}) : super(key: key);

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> with WidgetsBindingObserver {
  late RewardBloc _rewardBloc;
  int _currentPage = 1;
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  late FocusNode _screenFocusNode;
  
  @override
  void initState() {
    super.initState();
    _rewardBloc = BlocProvider.of<RewardBloc>(context);
    _screenFocusNode = FocusNode();
    WidgetsBinding.instance.addObserver(this);
    _loadRewards();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenFocusNode.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground
      _loadRewards();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure we have focus to detect when returning to this screen
    FocusScope.of(context).requestFocus(_screenFocusNode);
  }
  
  void _loadRewards() {
    _rewardBloc.add(LoadMyRewards(
      page: _currentPage,
      fromDate: _selectedFromDate != null 
          ? DateFormat('yyyy-MM-dd').format(_selectedFromDate!) 
          : null,
      toDate: _selectedToDate != null 
          ? DateFormat('yyyy-MM-dd').format(_selectedToDate!) 
          : null,
    ));
  }
  
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedFromDate != null && _selectedToDate != null
          ? DateTimeRange(start: _selectedFromDate!, end: _selectedToDate!)
          : null,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedFromDate = picked.start;
        _selectedToDate = picked.end;
        _currentPage = 1; // Reset to first page when filter changes
      });
      _loadRewards();
    }
  }
  
  void _clearDateFilter() {
    setState(() {
      _selectedFromDate = null;
      _selectedToDate = null;
      _currentPage = 1; // Reset to first page when filter changes
    });
    _loadRewards();
  }
  
  void _navigateToStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: _rewardBloc,
          child: const RewardStatisticsScreen(),
        ),
      ),
    ).then((_) => _loadRewards()); // Reload data when returning
  }
  
  void _navigateToRankings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: _rewardBloc,
          child: const RewardRankingsScreen(),
        ),
      ),
    ).then((_) => _loadRewards()); // Reload data when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // Chỉ hiển thị AppBar nếu không phải đang trong TabView
      appBar: widget.isInTabView ? null : AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Điểm thưởng',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildScreenContent(),
    );
  }
  
  Widget _buildScreenContent() {
    // Thêm phần header cho trường hợp hiển thị trong TabView
    return RefreshIndicator(
      onRefresh: () async {
        _loadRewards();
      },
      child: Column(
        children: [
          // Header chỉ hiển thị khi ở trong TabView
          if (widget.isInTabView)
            _buildHeader(),
          
          Expanded(
            child: BlocBuilder<RewardBloc, RewardState>(
              builder: (context, state) {
                if (state is RewardLoading) {
                  return const Center(child: LoadingIndicator());
                } else if (state is MyRewardsLoaded) {
                  return _buildRewardsContent(state);
                } else if (state is RewardError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: _loadRewards,
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
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Điểm thưởng của bạn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.leaderboard, color: AppColors.primaryGreen),
                onPressed: _navigateToRankings,
                tooltip: 'Bảng xếp hạng',
              ),
              IconButton(
                icon: const Icon(Icons.insert_chart, color: AppColors.primaryGreen),
                onPressed: _navigateToStatistics,
                tooltip: 'Thống kê',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardsContent(MyRewardsLoaded state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPointsCard(state.totalPoints),
          const SizedBox(height: 16),
          _buildFilterSection(),
          _buildHistoryTitle(state),
          if (state.rewards.isEmpty)
            _buildEmptyState()
          else
            _buildRewardsList(state.rewards),
          const SizedBox(height: 16),
          _buildPagination(state.pagination),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildPointsCard(int totalPoints) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars, color: Colors.yellow, size: 24),
              SizedBox(width: 8),
              Text(
                'Tổng điểm thưởng của bạn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '$totalPoints',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tích điểm để đổi những phần quà hấp dẫn!',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterSection() {
    String dateRangeText = 'Tất cả';
    if (_selectedFromDate != null && _selectedToDate != null) {
      final formatter = DateFormat('dd/MM/yyyy');
      dateRangeText = '${formatter.format(_selectedFromDate!)} - ${formatter.format(_selectedToDate!)}';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                dateRangeText,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGreen),
                foregroundColor: AppColors.primaryGreen,
              ),
              onPressed: () => _selectDateRange(context),
            ),
          ),
          if (_selectedFromDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: _clearDateFilter,
              tooltip: 'Xóa bộ lọc',
            ),
        ],
      ),
    );
  }
  
  Widget _buildHistoryTitle(MyRewardsLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Lịch sử điểm thưởng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          Text(
            'Tổng ${state.pagination.totalItems} mục',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch sử điểm thưởng',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tích điểm bằng cách tham gia các hoạt động',
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
  
  Widget _buildRewardsList(List<Reward> rewards) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rewards.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return _buildRewardItem(reward);
      },
    );
  }
  
  Widget _buildRewardItem(Reward reward) {
    final bool isPositive = reward.points > 0;
    final formatter = DateFormat('dd/MM/yyyy');
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      subtitle: Text(
        'Ngày: ${formatter.format(reward.earnedDate)}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Text(
        '${isPositive ? '+' : ''}${reward.points}',
        style: TextStyle(
          color: isPositive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
  
  Widget _buildPagination(Pagination pagination) {
    if (pagination.totalPages <= 1) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: _currentPage > 1 
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _loadRewards();
                  }
                : null,
            color: AppColors.primaryGreen,
            disabledColor: Colors.grey[300],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Trang $_currentPage/${pagination.totalPages}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: _currentPage < pagination.totalPages 
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _loadRewards();
                  }
                : null,
            color: AppColors.primaryGreen,
            disabledColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }
} 