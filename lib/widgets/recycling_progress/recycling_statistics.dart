import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/recycling_statistics_model.dart';

class RecyclingStatistics extends StatelessWidget {
  final Map<String, double> wasteTypeQuantities;
  final double totalWeight;
  final RecyclingStatisticsData? apiStatistics;
  
  const RecyclingStatistics({
    Key? key,
    required this.wasteTypeQuantities,
    required this.totalWeight,
    this.apiStatistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if API statistics are available
    if (apiStatistics != null) {
      return _buildAPIStatistics(context);
    }
    
    // Fall back to legacy statistics
    return _buildLegacyStatistics(context);
  }
  
  Widget _buildAPIStatistics(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê tái chế',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Show filter info
          Text(
            'Từ ${apiStatistics!.filters.from} đến ${apiStatistics!.filters.to}',
            style: TextStyle(
              fontSize: 13, 
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Total processes card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.eco,
                  color: AppColors.primaryGreen,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng số quy trình tái chế',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${apiStatistics!.totals.totalProcesses} quy trình',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${apiStatistics!.totals.totalProcessed.toStringAsFixed(2)} kg đã xử lý',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          _buildStatusSummary(),
          const SizedBox(height: 16),
          
          const Text(
            'Theo loại rác',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Waste type breakdown
          ...apiStatistics!.statistics.map((stat) => 
            _buildWasteTypeStatistics(context, stat),
          ),
          
          if (apiStatistics!.statistics.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Không có dữ liệu tái chế trong khoảng thời gian này',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatusSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Hoàn thành',
            apiStatistics!.totals.completedProcesses,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusCard(
            'Đang xử lý',
            apiStatistics!.totals.inProgressProcesses,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusCard(
            'Chờ xử lý',
            apiStatistics!.totals.pendingProcesses,
            Colors.blue,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusCard(String title, int count, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildWasteTypeStatistics(BuildContext context, WasteStatistic stat) {
    // Define colors based on waste type
    MaterialColor barColor;
    if (stat.wasteTypeName.toLowerCase().contains('giấy')) {
      barColor = Colors.blue;
    } else if (stat.wasteTypeName.toLowerCase().contains('nhựa')) {
      barColor = Colors.green;
    } else if (stat.wasteTypeName.toLowerCase().contains('nhôm') || 
               stat.wasteTypeName.toLowerCase().contains('kim loại')) {
      barColor = Colors.grey;
    } else if (stat.wasteTypeName.toLowerCase().contains('thủy tinh')) {
      barColor = Colors.amber;
    } else {
      barColor = Colors.teal;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.wasteTypeName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Số quy trình: ${stat.totalProcesses}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đã xử lý: ${stat.totalProcessed.toStringAsFixed(2)} kg',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoàn thành: ${stat.completedProcesses}',
                      style: TextStyle(fontSize: 13, color: Colors.green.shade700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đang xử lý: ${stat.inProgressProcesses}',
                      style: TextStyle(fontSize: 13, color: Colors.amber.shade700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chờ xử lý: ${stat.pendingProcesses}',
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: barColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: stat.completedProcesses / 
                          (stat.totalProcesses > 0 ? stat.totalProcesses : 1),
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyStatistics(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê tái chế',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Total weight card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.eco,
                  color: AppColors.primaryGreen,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng khối lượng tái chế',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalWeight.toStringAsFixed(2)} kg',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Theo loại rác',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Waste type breakdown
          ...wasteTypeQuantities.entries.map((entry) => 
            _buildWasteTypeProgressBar(
              context: context,
              label: entry.key,
              value: entry.value,
              maxValue: totalWeight,
            ),
          ),
          
          if (wasteTypeQuantities.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Không có dữ liệu tái chế trong khoảng thời gian này',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildWasteTypeProgressBar({
    required BuildContext context,
    required String label,
    required double value,
    required double maxValue,
  }) {
    // Define colors based on waste type
    MaterialColor barColor;
    if (label.toLowerCase().contains('giấy')) {
      barColor = Colors.blue;
    } else if (label.toLowerCase().contains('nhựa')) {
      barColor = Colors.green;
    } else if (label.toLowerCase().contains('nhôm') || label.toLowerCase().contains('kim loại')) {
      barColor = Colors.grey;
    } else if (label.toLowerCase().contains('thủy tinh')) {
      barColor = Colors.amber;
    } else {
      barColor = Colors.teal;
    }
    
    // Calculate percentage
    final double percentage = maxValue > 0 ? (value / maxValue) * 100 : 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${value.toStringAsFixed(2)} kg (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
} 