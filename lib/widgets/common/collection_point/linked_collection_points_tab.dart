// widgets/collection_point/linked_collection_points_tab.dart
import 'package:flutter/material.dart';
import 'package:wasteanmagement/widgets/common/confirmation_dialog.dart';
import '../../../utils/app_colors.dart';
import '../../models/collection_point_model.dart';

class LinkedCollectionPointsTab extends StatelessWidget {
  final int wasteTypeId;
  final List<CollectionPoint> collectionPoints;
  final Function(int) onUnlinkCollectionPoint;

  const LinkedCollectionPointsTab({
    Key? key,
    required this.wasteTypeId,
    required this.collectionPoints,
    required this.onUnlinkCollectionPoint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (collectionPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có điểm thu gom nào được liên kết',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Switch to the Add Collection Points tab
                DefaultTabController.of(context).animateTo(1);
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm điểm thu gom'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: BorderSide(color: AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: collectionPoints.length,
      itemBuilder: (context, index) {
        final collectionPoint = collectionPoints[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collectionPoint.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            collectionPoint.address,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.link_off, color: Colors.red),
                      tooltip: 'Xóa liên kết',
                      onPressed: () {
                        _showUnlinkConfirmation(
                          context,
                          collectionPoint.id,
                          collectionPoint.name,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.access_time,
                      collectionPoint.operating_hours,
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.dashboard,
                      '${collectionPoint.current_load}/${collectionPoint.capacity} kg',
                      Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.check_circle,
                      _getStatusText(collectionPoint.status),
                      _getStatusColor(collectionPoint.status),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showUnlinkConfirmation(BuildContext context, int collectionPointId, String name) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Xóa liên kết',
        content: 'Bạn có chắc chắn muốn xóa liên kết với điểm thu gom "$name" không?',
        confirmText: 'Xóa liên kết',
        cancelText: 'Hủy',
        onConfirm: () {
          Navigator.of(context).pop();
          onUnlinkCollectionPoint(collectionPointId);
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.primaryGreen;
      case 'inactive':
        return Colors.grey;
      case 'full':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Đang mở cửa';
      case 'inactive':
        return 'Đã đóng cửa';
      case 'full':
        return 'Đã đầy';
      default:
        return 'Không xác định';
    }
  }
}