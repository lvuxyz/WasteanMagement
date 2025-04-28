import 'package:flutter/material.dart';
import 'package:wasteanmagement/models/collection_point_model.dart';

class CollectionPointCard extends StatelessWidget {
  final CollectionPoint collectionPoint;
  final VoidCallback? onTap;
  final VoidCallback? onUnlink;
  final bool showUnlinkButton;

  const CollectionPointCard({
    Key? key,
    required this.collectionPoint,
    this.onTap,
    this.onUnlink,
    this.showUnlinkButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị hình ảnh nếu có
              if (collectionPoint.imageUrl != null && collectionPoint.imageUrl!.isNotEmpty)
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(collectionPoint.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(Icons.place, size: 40, color: Colors.grey),
                ),
              
              // Thông tin điểm thu gom
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
                    const SizedBox(height: 8),
                    
                    // Trạng thái và công suất
                    Row(
                      children: [
                        _buildStatusIndicator(collectionPoint.status),
                        const SizedBox(width: 12),
                        _buildCapacityIndicator(
                          collectionPoint.current_load / collectionPoint.capacity
                        ),
                      ],
                    ),
                    
                    // Giờ hoạt động
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          collectionPoint.operating_hours,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Nút hủy liên kết nếu cần
              if (showUnlinkButton)
                IconButton(
                  onPressed: onUnlink,
                  icon: const Icon(Icons.link_off, color: Colors.red),
                  tooltip: 'Hủy liên kết điểm thu gom',
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị trạng thái của điểm thu gom
  Widget _buildStatusIndicator(String status) {
    Color statusColor;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'Đang hoạt động';
        break;
      case 'inactive':
        statusColor = Colors.red;
        statusText = 'Tạm ngưng';
        break;
      case 'maintenance':
        statusColor = Colors.orange;
        statusText = 'Bảo trì';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Widget hiển thị công suất của điểm thu gom
  Widget _buildCapacityIndicator(double fillRatio) {
    Color capacityColor;
    String capacityText;
    
    if (fillRatio < 0.5) {
      capacityColor = Colors.green;
      capacityText = 'Còn trống';
    } else if (fillRatio < 0.8) {
      capacityColor = Colors.orange;
      capacityText = 'Gần đầy';
    } else {
      capacityColor = Colors.red;
      capacityText = 'Đầy';
    }
    
    return Row(
      children: [
        Container(
          width: 50,
          height: 10,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(5),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Container(
                    width: constraints.maxWidth * fillRatio,
                    decoration: BoxDecoration(
                      color: capacityColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 6),
        Text(
          capacityText,
          style: TextStyle(
            fontSize: 12,
            color: capacityColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 