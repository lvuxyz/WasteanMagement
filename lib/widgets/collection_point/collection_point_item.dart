import 'package:flutter/material.dart';
import '../../models/collection_point_model.dart';
import '../../utils/app_colors.dart';

class CollectionPointItem extends StatelessWidget {
  final CollectionPoint collectionPoint;
  final String actionButtonText;
  final IconData actionButtonIcon;
  final Color actionButtonColor;
  final VoidCallback onActionPressed;

  const CollectionPointItem({
    Key? key,
    required this.collectionPoint,
    required this.actionButtonText,
    required this.actionButtonIcon,
    required this.actionButtonColor,
    required this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final capacityPercentage = 
        (collectionPoint.current_load / collectionPoint.capacity * 100).toInt();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor(collectionPoint.status).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header with name and status
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(collectionPoint.status).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(collectionPoint.status),
                      color: _getStatusColor(collectionPoint.status),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collectionPoint.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          collectionPoint.address,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(collectionPoint.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(collectionPoint.status).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(collectionPoint.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(collectionPoint.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Info row (hours, capacity)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  // Hours
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.access_time_outlined,
                            color: Colors.orange,
                            size: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            collectionPoint.operating_hours,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Capacity
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCapacityColor(capacityPercentage).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getCapacityColor(capacityPercentage).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$capacityPercentage% đầy',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getCapacityColor(capacityPercentage),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Action button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: actionButtonColor.withOpacity(0.05),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: TextButton.icon(
                onPressed: onActionPressed,
                icon: Icon(
                  actionButtonIcon,
                  size: 16,
                  color: actionButtonColor,
                ),
                label: Text(
                  actionButtonText,
                  style: TextStyle(
                    color: actionButtonColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getCapacityColor(int percentage) {
    if (percentage > 90) {
      return Colors.red;
    } else if (percentage > 70) {
      return Colors.orange;
    } else if (percentage > 40) {
      return Colors.amber;
    } else {
      return AppColors.primaryGreen;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.primaryGreen;
      case 'inactive':
        return Colors.grey;
      case 'full':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle_outline;
      case 'inactive':
        return Icons.pause_circle_outline;
      case 'full':
        return Icons.warning_amber_outlined;
      case 'maintenance':
        return Icons.build_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Đang hoạt động';
      case 'inactive':
        return 'Tạm ngưng';
      case 'full':
        return 'Đã đầy';
      case 'maintenance':
        return 'Đang bảo trì';
      default:
        return 'Không xác định';
    }
  }
} 