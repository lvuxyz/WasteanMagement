import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;

  const LoadingIndicator({
    super.key,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.color = AppColors.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
} 