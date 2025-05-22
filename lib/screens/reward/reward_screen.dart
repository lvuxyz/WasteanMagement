import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
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
  final _scrollController = ScrollController();
  bool _isFilterExpanded = false;
  
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
    _scrollController.dispose();
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
    // Format dates in yyyy-MM-dd format for API
    final String? fromDateStr = _selectedFromDate != null 
        ? DateFormat('yyyy-MM-dd').format(_selectedFromDate!) 
        : null;
    final String? toDateStr = _selectedToDate != null 
        ? DateFormat('yyyy-MM-dd').format(_selectedToDate!) 
        : null;
    
    // Debug logs to verify filter values
    if (fromDateStr != null || toDateStr != null) {
      developer.log('Applying date filter - From: $fromDateStr, To: $toDateStr');
    }
    
    _rewardBloc.add(LoadMyRewards(
      page: _currentPage,
      fromDate: fromDateStr,
      toDate: toDateStr,
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
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        // Set the time to start of day for fromDate and end of day for toDate for more accurate filtering
        _selectedFromDate = DateTime(picked.start.year, picked.start.month, picked.start.day, 0, 0, 0);
        _selectedToDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
        _currentPage = 1; // Reset to first page when filter changes
      });
      // We'll wait for the Apply button instead of loading immediately
      developer.log('Date range selected: ${_selectedFromDate!.toIso8601String()} - ${_selectedToDate!.toIso8601String()}');
    }
  }
  
  void _clearDateFilter() {
    setState(() {
      _selectedFromDate = null;
      _selectedToDate = null;
      _currentPage = 1; // Reset to first page when filter changes
      _isFilterExpanded = false;
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
      backgroundColor: Colors.grey[50],
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
        elevation: 0,
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
      color: AppColors.primaryGreen,
      child: BlocBuilder<RewardBloc, RewardState>(
        builder: (context, state) {
          if (state is RewardLoading && _currentPage == 1) {
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
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
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
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _navigateToRankings,
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Tooltip(
                      message: 'Bảng xếp hạng',
                      child: Icon(
                        Icons.leaderboard_rounded, 
                        color: AppColors.primaryGreen.withOpacity(0.9),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _navigateToStatistics,
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Tooltip(
                      message: 'Thống kê',
                      child: Icon(
                        Icons.insert_chart_rounded, 
                        color: AppColors.primaryGreen.withOpacity(0.9),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardsContent(MyRewardsLoaded state) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Header only shown in tab view
        if (widget.isInTabView)
          SliverToBoxAdapter(child: _buildHeader()),
          
        // Points card
        SliverToBoxAdapter(child: _buildPointsCard(state.totalPoints)),
        
        // Filter section
        SliverToBoxAdapter(child: _buildFilterSection()),
        
        // History title
        SliverToBoxAdapter(child: _buildHistoryTitle(state)),
        
        // Rewards list or empty state
        if (state.rewards.isEmpty)
          SliverToBoxAdapter(child: _buildEmptyState())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildRewardItem(state.rewards[index]),
              childCount: state.rewards.length,
            ),
          ),
          
        // Pagination
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildPagination(state.pagination),
              const SizedBox(height: 24), // Extra padding at bottom
            ],
          ),
        ),
        
        // Show loading indicator at bottom when loading more pages
        if (state is RewardLoading && _currentPage > 1)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: LoadingIndicator()),
            ),
          ),
      ],
    );
  }
  
  Widget _buildPointsCard(int totalPoints) {
    final formattedPoints = NumberFormat('#,###').format(totalPoints);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToStatistics,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        color: Colors.yellow,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Tổng điểm thưởng của bạn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  formattedPoints,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tích điểm để đổi những phần quà hấp dẫn!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFilterSection() {
    String dateRangeText = 'Tất cả';
    if (_selectedFromDate != null && _selectedToDate != null) {
      final formatter = DateFormat('dd/MM/yyyy');
      dateRangeText = '${formatter.format(_selectedFromDate!)} - ${formatter.format(_selectedToDate!)}';
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: EdgeInsets.all(_isFilterExpanded ? 12 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isFilterExpanded ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ] : null,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.filter_list_rounded,
                          color: AppColors.primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bộ lọc',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (_selectedFromDate != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Đã áp dụng',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    AnimatedRotation(
                      turns: _isFilterExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          if (_isFilterExpanded) ...[
            const Divider(height: 1),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khoảng thời gian',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
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
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onPressed: () => _selectDateRange(context),
                      ),
                    ),
                    
                    if (_selectedFromDate != null) ...[
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: _clearDateFilter,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.clear,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isFilterExpanded = false;
                        _selectedFromDate = null;
                        _selectedToDate = null;
                        _currentPage = 1;
                      });
                      _loadRewards();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Đặt lại'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _isFilterExpanded = false);
                      
                      // Provide feedback when filter is applied
                      if (_selectedFromDate != null && _selectedToDate != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã lọc từ ${DateFormat('dd/MM/yyyy').format(_selectedFromDate!)} đến ${DateFormat('dd/MM/yyyy').format(_selectedToDate!)}'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      
                      _loadRewards();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildHistoryTitle(MyRewardsLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Lịch sử điểm thưởng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Tổng ${state.pagination.totalItems} mục',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
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
            _selectedFromDate != null ? Icons.filter_list : Icons.hourglass_empty,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFromDate != null 
                ? 'Không tìm thấy kết quả'
                : 'Chưa có lịch sử điểm thưởng',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFromDate != null
                ? 'Không có điểm thưởng nào trong khoảng thời gian đã chọn'
                : 'Tích điểm bằng cách tham gia các hoạt động',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_selectedFromDate != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Đặt lại bộ lọc'),
              onPressed: _clearDateFilter,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildRewardItem(Reward reward) {
    final bool isPositive = reward.points > 0;
    final bool isZero = reward.points == 0;
    final formatter = DateFormat('dd/MM/yyyy');
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isPositive 
                ? Colors.green.withOpacity(0.1)
                : isZero 
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isPositive 
                  ? Icons.add_circle
                  : isZero
                      ? Icons.remove_circle_outline
                      : Icons.remove_circle,
              color: isPositive
                  ? Colors.green
                  : isZero
                      ? Colors.orange
                      : Colors.red,
              size: 28,
            ),
          ),
        ),
        title: Text(
          reward.source,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  formatter.format(reward.earnedDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.withOpacity(0.1)
                : isZero
                    ? Colors.transparent
                    : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isPositive
                ? '+${reward.points}'
                : '${reward.points}',
            style: TextStyle(
              color: isPositive
                  ? Colors.green
                  : isZero
                      ? Colors.grey[600]
                      : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPagination(Pagination pagination) {
    if (pagination.totalPages <= 1) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPageButton(
            icon: Icons.arrow_back_ios,
            onPressed: _currentPage > 1 
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _loadRewards();
                    // Scroll to top when changing pages
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
          
          const SizedBox(width: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Trang $_currentPage/${pagination.totalPages}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          _buildPageButton(
            icon: Icons.arrow_forward_ios,
            onPressed: _currentPage < pagination.totalPages 
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _loadRewards();
                    // Scroll to top when changing pages
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPageButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 16,
            color: onPressed != null 
                ? AppColors.primaryGreen 
                : Colors.grey[300],
          ),
        ),
      ),
    );
  }
} 