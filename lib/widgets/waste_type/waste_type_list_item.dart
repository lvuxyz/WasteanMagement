// widgets/waste_type/waste_type_list_item.dart
import 'package:flutter/material.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';

class WasteTypeListItem extends StatelessWidget {
  final WasteType wasteType;
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onManageCollectionPoints;

  const WasteTypeListItem({
    Key? key,
    required this.wasteType,
    required this.onView,
    this.onEdit,
    this.onDelete,
    this.onManageCollectionPoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Xác định màu sắc dựa trên loại rác
    final bool isHazardous = wasteType.category == 'Nguy hại';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isHazardous
              ? Colors.red.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Header với thông tin cơ bản và icon
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: wasteType.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      wasteType.icon,
                      color: wasteType.color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wasteType.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(wasteType.category).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                wasteType.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getCategoryColor(wasteType.category),
                                ),
                              ),
                            ),
                            if (wasteType.buyingPrice > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${wasteType.buyingPrice}đ/${wasteType.unit}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  _buildActionMenu(),
                ],
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                wasteType.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu() {
    // Only show menu if at least one action is available
    if (onEdit == null && onDelete == null && onManageCollectionPoints == null) {
      return Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            if (onEdit != null) onEdit!();
            break;
          case 'delete':
            if (onDelete != null) onDelete!();
            break;
          case 'manage_collection_points':
            if (onManageCollectionPoints != null) onManageCollectionPoints!();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: AppColors.primaryGreen),
                SizedBox(width: 8),
                Text('Chỉnh sửa'),
              ],
            ),
          ),
        if (onManageCollectionPoints != null)
          PopupMenuItem<String>(
            value: 'manage_collection_points',
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 8),
                Text('Quản lý điểm thu gom'),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Xóa'),
              ],
            ),
          ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Tái chế':
        return Colors.blue;
      case 'Hữu cơ':
        return Colors.green;
      case 'Nguy hại':
        return Colors.red;
      case 'Thường':
        return Colors.grey;
      default:
        return AppColors.primaryGreen;
    }
  }
}
