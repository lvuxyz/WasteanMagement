// widgets/waste_type/waste_type_collection_points_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/collection_point_model.dart';
import '../../utils/app_colors.dart';
import '../../blocs/admin/admin_cubit.dart';

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
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: collectionPoints.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final collectionPoint = collectionPoints[index];
        final capacityPercentage = 
          ((collectionPoint.currentLoad ?? 0) / collectionPoint.capacity * 100).toInt();

        return _buildCollectionPointCard(collectionPoint, capacityPercentage, context);
      },
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có điểm thu gom nào',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loại rác thải này chưa được thu gom tại bất kỳ điểm nào',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            BlocBuilder<AdminCubit, bool>(
              builder: (context, isAdminState) {
                final showAdminFeatures = isAdmin || isAdminState;
                return showAdminFeatures
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/waste-type/collection-points',
                          arguments: wasteTypeId,
                        ).then((result) {
                          // Refresh data if changes were made
                          if (result == true) {
                            // This is part of waste management functionality
                            // Reload this screen with updated data
                            Navigator.of(context).pop();  // Close current screen
                            Navigator.pushReplacementNamed(
                              context,
                              '/waste-type/details',
                              arguments: wasteTypeId,
                            );
                          }
                        });
                      },
                      icon: const Icon(Icons.add_location_alt),
                      label: const Text('Thêm điểm thu gom'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCollectionPointCard(CollectionPoint point, int capacityPercentage, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Capacity bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getCapacityColor(capacityPercentage),
                  _getCapacityColor(capacityPercentage).withOpacity(0.7),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and status
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(point.status).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(point.status),
                        color: _getStatusColor(point.status),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            point.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(point.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getStatusColor(point.status).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(point.status),
                                  size: 12,
                                  color: _getStatusColor(point.status),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _getStatusText(point.status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(point.status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Address and hours
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  text: point.address,
                  color: Colors.indigo,
                ),
                
                const SizedBox(height: 8),
                
                _buildInfoRow(
                  icon: Icons.access_time_outlined,
                  text: point.operatingHours,
                  color: Colors.orange,
                ),
                
                const SizedBox(height: 16),
                
                // Capacity indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Công suất thu gom',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${capacityPercentage}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getCapacityColor(capacityPercentage),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (point.currentLoad ?? 0) / point.capacity,
                        backgroundColor: Colors.grey[200],
                        minHeight: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getCapacityColor(capacityPercentage),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${point.currentLoad ?? 0}/${point.capacity} kg hiện đang lưu trữ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                // Actions
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Open phone dialer
                          // launch("tel:${point.phone}");
                        },
                        icon: const Icon(
                          Icons.phone_outlined,
                          size: 18,
                        ),
                        label: const Text('Gọi điện'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Open map directions
                          // launchMap(point.lat, point.lng);
                        },
                        icon: const Icon(
                          Icons.directions_outlined,
                          size: 18,
                        ),
                        label: const Text('Chỉ đường'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Admin actions
                if (isAdmin) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // Show confirmation dialog to unlink collection point
                          _showUnlinkConfirmationDialog(context, point);
                        },
                        icon: const Icon(
                          Icons.link_off,
                          size: 16,
                        ),
                        label: const Text('Xóa liên kết'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
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
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  void _showUnlinkConfirmationDialog(BuildContext context, CollectionPoint point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa liên kết'),
        content: Text(
          'Bạn có chắc chắn muốn xóa liên kết với điểm thu gom "${point.name}" không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle unlink action
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Xóa liên kết'),
          ),
        ],
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