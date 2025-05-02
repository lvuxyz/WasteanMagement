import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class RecyclingStatistics extends StatelessWidget {
  final Map<String, double> wasteTypeQuantities;
  final double totalWeight;
  
  const RecyclingStatistics({
    Key? key,
    required this.wasteTypeQuantities,
    required this.totalWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    Color barColor;
    if (label.toLowerCase().contains('giấy')) {
      barColor = Colors.blue;
    } else if (label.toLowerCase().contains('nhựa')) {
      barColor = Colors.green;
    } else if (label.toLowerCase().contains('nhôm') || label.toLowerCase().contains('kim loại')) {
      barColor = Colors.grey.shade700;
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