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
      _loadRewards();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).requestFocus(_screenFocusNode);
  }

  void _loadRewards() {
    final String? fromDateStr = _selectedFromDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedFromDate!)
        : null;
    final String? toDateStr = _selectedToDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedToDate!)
        : null;

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
        _selectedFromDate = DateTime(picked.start.year, picked.start.month, picked.start.day, 0, 0, 0);
        _selectedToDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
        _currentPage = 1;
      });
      developer.log('Date range selected: ${_selectedFromDate!.toIso8601String()} - ${_selectedToDate!.toIso8601String()}');
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedFromDate = null;
      _selectedToDate = null;
      _currentPage = 1;
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
    ).then((_) => _loadRewards());
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
    ).then((_) => _loadRewards());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
      body: SafeArea(
        bottom: !widget.isInTabView, // Only add bottom padding if not in tab view
        child: _buildScreenContent(),
      ),
    );
  }

  Widget _buildScreenContent() {
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
          return const Center(child: LoadingIndicator());
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Điểm thưởng của bạn',
            style: TextStyle(
              fontSize: 16,
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
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.leaderboard_rounded,
                      color: AppColors.primaryGreen.withOpacity(0.8),
                      size: 22,
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _navigateToStatistics,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.insert_chart_rounded,
                      color: AppColors.primaryGreen.withOpacity(0.8),
                      size: 22,
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
    // Get the bottom padding to account for navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Header trong tab view
        if (widget.isInTabView)
          SliverToBoxAdapter(child: _buildHeader()),

        // Points card - tối ưu chiều cao
        SliverToBoxAdapter(child: _buildCompactPointsCard(state.totalPoints)),

        // Filter section - thu gọn
        SliverToBoxAdapter(child: _buildCompactFilterSection()),

        // History title - giảm padding
        SliverToBoxAdapter(child: _buildCompactHistoryTitle(state)),

        // Rewards list hoặc empty state
        if (state.rewards.isEmpty)
          SliverToBoxAdapter(child: _buildCompactEmptyState())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildCompactRewardItem(state.rewards[index]),
              childCount: state.rewards.length,
            ),
          ),

        // Pagination - tối ưu
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildCompactPagination(state.pagination),
              // Add extra padding at the bottom to prevent content from being hidden by the navigation bar
              SizedBox(height: bottomPadding > 0 ? bottomPadding : 16),
            ],
          ),
        ),

        if (state is RewardLoading && _currentPage > 1)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Center(child: LoadingIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactPointsCard(int totalPoints) {
    final formattedPoints = NumberFormat('#,###').format(totalPoints);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToStatistics,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: Colors.yellow,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tổng điểm thưởng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedPoints,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactFilterSection() {
    String dateRangeText = 'Tất cả';
    if (_selectedFromDate != null && _selectedToDate != null) {
      final formatter = DateFormat('dd/MM');
      dateRangeText = '${formatter.format(_selectedFromDate!)} - ${formatter.format(_selectedToDate!)}';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: _isFilterExpanded ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ] : null,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list_rounded,
                      color: AppColors.primaryGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateRangeText,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (_selectedFromDate != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '●',
                          style: TextStyle(
                            fontSize: 8,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    AnimatedRotation(
                      turns: _isFilterExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_isFilterExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 14),
                          label: Text(
                            _selectedFromDate != null
                                ? '${DateFormat('dd/MM/yyyy').format(_selectedFromDate!)} - ${DateFormat('dd/MM/yyyy').format(_selectedToDate!)}'
                                : 'Chọn thời gian',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                            side: const BorderSide(color: AppColors.primaryGreen, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(
                                Icons.clear,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
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
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text('Đặt lại', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _isFilterExpanded = false);
                            _loadRewards();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text('Áp dụng', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactHistoryTitle(MyRewardsLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Lịch sử điểm thưởng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${state.pagination.totalItems}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedFromDate != null ? Icons.filter_list : Icons.hourglass_empty,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            _selectedFromDate != null
                ? 'Không tìm thấy kết quả'
                : 'Chưa có lịch sử điểm thưởng',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedFromDate != null
                ? 'Thử thay đổi khoảng thời gian'
                : 'Tích điểm bằng cách tham gia hoạt động',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRewardItem(Reward reward) {
    final bool isPositive = reward.points > 0;
    final bool isZero = reward.points == 0;
    final formatter = DateFormat('dd/MM');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.withOpacity(0.1)
                : isZero
                ? Colors.orange.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
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
            size: 20,
          ),
        ),
        title: Text(
          reward.source,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          formatter.format(reward.earnedDate),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.withOpacity(0.1)
                : isZero
                ? Colors.transparent
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
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
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPagination(Pagination pagination) {
    if (pagination.totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCompactPageButton(
            icon: Icons.arrow_back_ios,
            onPressed: _currentPage > 1
                ? () {
              setState(() {
                _currentPage--;
              });
              _loadRewards();
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
                : null,
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '$_currentPage/${pagination.totalPages}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: 12),

          _buildCompactPageButton(
            icon: Icons.arrow_forward_ios,
            onPressed: _currentPage < pagination.totalPages
                ? () {
              setState(() {
                _currentPage++;
              });
              _loadRewards();
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

  Widget _buildCompactPageButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            icon,
            size: 14,
            color: onPressed != null
                ? AppColors.primaryGreen
                : Colors.grey[300],
          ),
        ),
      ),
    );
  }
}