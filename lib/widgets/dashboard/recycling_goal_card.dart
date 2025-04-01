import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/recycling_goal_model.dart';

class RecyclingGoalCard extends StatelessWidget {
  final RecyclingGoal goal;

  const RecyclingGoalCard({
    Key? key,
    required this.goal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = goal.progressPercentage;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mục tiêu tháng: ${goal.targetAmount.toInt()}${goal.currentAmount > 0 ? "kg" : ""}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                // Background progress bar
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.progressBackground,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                // Progress indicator
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${goal.remainingAmount.toStringAsFixed(1)}kg còn lại',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 