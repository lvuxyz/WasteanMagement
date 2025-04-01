import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/recent_activity_model.dart';

class RecentActivityItem extends StatelessWidget {
  final RecentActivity activity;

  const RecentActivityItem({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(),
              color: AppColors.successGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
                if (activity.activityType == 'waste_sorting' && activity.details.containsKey('waste_name'))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                        children: [
                          TextSpan(
                            text: '${activity.details['quantity']} ',
                          ),
                          TextSpan(
                            text: '${activity.details['unit']} ',
                          ),
                          TextSpan(
                            text: activity.details['waste_name'],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  activity.formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (activity.iconType) {
      case 'check_circle':
        return Icons.check_circle;
      case 'calendar':
        return Icons.calendar_today;
      case 'points':
        return Icons.stars;
      default:
        return Icons.info;
    }
  }
} 