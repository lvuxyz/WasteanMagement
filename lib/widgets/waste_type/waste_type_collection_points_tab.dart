
// widgets/waste_type/waste_type_collection_points_tab.dart
import 'package:flutter/material.dart';
import '../../models/collection_point_model.dart';
import '../../utils/app_colors.dart';

class WasteTypeCollectionPointsTab extends StatelessWidget {
  final int wasteTypeId;
  final List<CollectionPoint> collectionPoints;
  final bool isAdmin;

  const WasteTypeCollectionPointsTab({
    Key? key,
    required this.wasteTypeId,
    required this.collectionPoints,
    required this.isAdmin,
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
              'Chưa có điểm thu gom nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            if (isAdmin)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/collection-points',
                    arguments: wasteTypeId,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm điểm thu gom'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
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
        final capacityPercentage =
        (collectionPoint.current_load / collectionPoint.capacity * 100).toInt();

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: _getCapacityColor(capacityPercentage),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            collectionPoint.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(collectionPoint.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusText(collectionPoint.status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(collectionPoint.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            collectionPoint.address,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          collectionPoint.operating_hours,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: collectionPoint.current_load / collectionPoint.capacity,
                        backgroundColor: Colors.grey[200],
                        minHeight: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getCapacityColor(capacityPercentage),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Công suất:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${collectionPoint.current_load}/${collectionPoint.capacity} kg (${capacityPercentage}%)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getCapacityColor(capacityPercentage),
                          ),
                        ),
                      ],
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              // Open Map navigation
                            },
                            icon: const Icon(
                              Icons.map,
                              size: 18,
                            ),
                            label: const Text('Xem bản đồ'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCapacityColor(int percentage) {
    if (percentage > 80) {
      return Colors.red;
    } else if (percentage > 50) {
      return Colors.orange;
    } else {
      return AppColors.primaryGreen;
    }
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