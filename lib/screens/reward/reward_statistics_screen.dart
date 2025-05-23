import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/blocs/reward/reward_bloc.dart';
import 'package:wasteanmagement/blocs/reward/reward_event.dart';
import 'package:wasteanmagement/blocs/reward/reward_state.dart';
import 'package:wasteanmagement/models/reward.dart';
import 'package:wasteanmagement/utils/app_colors.dart';
import 'package:wasteanmagement/widgets/common/loading_indicator.dart';
import 'package:wasteanmagement/widgets/common/error_view.dart';
import 'package:fl_chart/fl_chart.dart';

class RewardStatisticsScreen extends StatefulWidget {
  const RewardStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<RewardStatisticsScreen> createState() => _RewardStatisticsScreenState();
}

class _RewardStatisticsScreenState extends State<RewardStatisticsScreen> {
  String _currentPeriod = 'monthly';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }
  
  void _loadStatistics() {
    setState(() {
      _isLoading = true;
    });
    
    context.read<RewardBloc>().add(LoadMyStatistics(period: _currentPeriod));
  }
  
  void _changePeriod(String period) {
    if (period == _currentPeriod) return;
    
    setState(() {
      _currentPeriod = period;
      _isLoading = true;
    });
    
    _loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Thống kê điểm thưởng',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<RewardBloc, RewardState>(
          listener: (context, state) {
            if (state is StatisticsLoaded) {
              setState(() {
                _isLoading = false;
              });
            } else if (state is RewardError) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          builder: (context, state) {
            if (_isLoading) {
              return const Center(child: LoadingIndicator());
            } else if (state is StatisticsLoaded) {
              return _buildStatisticsContent(state);
            } else if (state is RewardError) {
              return ErrorView(
                message: state.message,
                onRetry: _loadStatistics,
                title: 'Lỗi tải dữ liệu',
              );
            }
            // Initial state or unexpected state
            return const Center(child: LoadingIndicator());
          },
        ),
      ),
    );
  }
  
  Widget _buildStatisticsContent(StatisticsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPeriodSelector(),
        const SizedBox(height: 16),
        if (state.statistics.isEmpty)
          _buildEmptyState()
        else
          Expanded(
            child: _buildChart(state),
          ),
      ],
    );
  }
  
  Widget _buildPeriodSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildPeriodButton('daily', 'Hàng ngày')),
          const SizedBox(width: 8),
          Expanded(child: _buildPeriodButton('weekly', 'Hàng tuần')),
          const SizedBox(width: 8),
          Expanded(child: _buildPeriodButton('monthly', 'Hàng tháng')),
          const SizedBox(width: 8),
          Expanded(child: _buildPeriodButton('yearly', 'Hàng năm')),
        ],
      ),
    );
  }
  
  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _currentPeriod == period;
    
    return ElevatedButton(
      onPressed: () => _changePeriod(period),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primaryGreen : Colors.white,
        foregroundColor: isSelected ? Colors.white : AppColors.primaryGreen,
        elevation: isSelected ? 2 : 0,
        side: BorderSide(
          color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có dữ liệu thống kê',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tích điểm để xem thống kê chi tiết',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChart(StatisticsLoaded state) {
    // Customize based on period
    String title = '';
    switch (_currentPeriod) {
      case 'daily':
        title = 'Thống kê theo ngày';
        break;
      case 'weekly':
        title = 'Thống kê theo tuần';
        break;
      case 'monthly':
        title = 'Thống kê theo tháng';
        break;
      case 'yearly':
        title = 'Thống kê theo năm';
        break;
    }
    
    // Get the bottom padding to account for navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildBarChart(state.statistics),
          ),
          const SizedBox(height: 16),
          _buildStatsSummary(state.statistics),
          // Add extra padding at the bottom to prevent content from being hidden by the navigation bar
          SizedBox(height: bottomPadding > 0 ? bottomPadding : 16),
        ],
      ),
    );
  }
  
  Widget _buildBarChart(List<RewardStatistics> statistics) {
    final maxY = _getMaxPoints(statistics);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: BarChart(
        BarChartData(
          barGroups: _getBarGroups(statistics),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(
                color: Color(0xFFEEEEEE),
                width: 1,
              ),
              left: BorderSide(
                color: Color(0xFFEEEEEE),
                width: 1,
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFFEEEEEE),
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final int idx = value.toInt();
                  if (idx < 0 || idx >= statistics.length) {
                    return const SizedBox();
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _getPeriodLabel(statistics[idx].period),
                      style: const TextStyle(
                        color: Color(0xFF7C7C7C),
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: Color(0xFF7C7C7C),
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.white,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final statistics = this.statistics[groupIndex];
                return BarTooltipItem(
                  '${statistics.totalPoints} điểm\n${statistics.rewardCount} lượt',
                  const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  
  List<BarChartGroupData> _getBarGroups(List<RewardStatistics> statistics) {
    final List<BarChartGroupData> barGroups = [];
    
    for (int i = 0; i < statistics.length; i++) {
      final stat = statistics[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: stat.totalPoints.toDouble(),
              width: 16,
              color: AppColors.primaryGreen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    
    return barGroups;
  }
  
  double _getMaxPoints(List<RewardStatistics> statistics) {
    if (statistics.isEmpty) return 100;
    
    final maxPoints = statistics
        .map((e) => e.totalPoints)
        .reduce((value, element) => value > element ? value : element);
    
    // Add 20% buffer for better visualization
    return (maxPoints * 1.2).toDouble();
  }
  
  String _getPeriodLabel(String period) {
    // Customize the label based on the period type
    switch (_currentPeriod) {
      case 'daily':
        // Assuming format like '2023-01-01'
        return period.substring(8, 10);
      case 'weekly':
        // Assuming format like 'W1-2023'
        return period.substring(0, 2);
      case 'monthly':
        // Assuming format like '01-2023'
        final parts = period.split('-');
        final Map<String, String> monthNames = {
          '01': 'T1', '02': 'T2', '03': 'T3', '04': 'T4',
          '05': 'T5', '06': 'T6', '07': 'T7', '08': 'T8',
          '09': 'T9', '10': 'T10', '11': 'T11', '12': 'T12',
        };
        return monthNames[parts[0]] ?? parts[0];
      case 'yearly':
        // Assuming format like '2023'
        return period;
      default:
        return period;
    }
  }
  
  Widget _buildStatsSummary(List<RewardStatistics> statistics) {
    final totalPoints = statistics.fold(0, (prev, stat) => prev + stat.totalPoints);
    final totalCount = statistics.fold(0, (prev, stat) => prev + stat.rewardCount);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Tổng kết',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Tổng điểm',
                '$totalPoints',
                Icons.stars,
                AppColors.primaryGreen,
              ),
              _buildStatItem(
                'Số lượt',
                '$totalCount',
                Icons.event,
                Colors.blue,
              ),
              _buildStatItem(
                'Trung bình',
                totalCount > 0 ? '${(totalPoints / totalCount).toStringAsFixed(1)}' : '0',
                Icons.trending_up,
                Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
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
  
  List<RewardStatistics> get statistics {
    final state = context.read<RewardBloc>().state;
    if (state is StatisticsLoaded) {
      return state.statistics;
    }
    return [];
  }
} 