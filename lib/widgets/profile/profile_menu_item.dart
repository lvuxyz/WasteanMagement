import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color textColor;
  final bool showArrow;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor = AppColors.primaryGreen,
    this.textColor = Colors.black87, // Changed from AppColors.primaryText
    this.showArrow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600], // Changed from AppColors.secondaryText
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}