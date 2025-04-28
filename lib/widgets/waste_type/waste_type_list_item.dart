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
    final bool isRecyclable = wasteType.category == 'Tái chế';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: isHazardous 
          ? Colors.red.withOpacity(0.2)
          : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isHazardous
              ? Colors.red.withOpacity(0.3)
              : isRecyclable
                  ? AppColors.primaryGreen.withOpacity(0.3)
                  : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header với thông tin cơ bản và icon
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: wasteType.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: wasteType.color.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
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
                        const SizedBox(height: 6),
                        
                        // Category badges
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildBadge(
                              wasteType.category,
                              _getCategoryColor(wasteType.category),
                              icon: _getCategoryIcon(wasteType.category),
                            ),
                            if (wasteType.buyingPrice > 0)
                              _buildBadge(
                                '${wasteType.buyingPrice}đ/${wasteType.unit}',
                                Colors.orange,
                                icon: Icons.monetization_on_outlined,
                              ),
                          ],
                        ),
                        
                        // Description
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            wasteType.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  _buildActionMenu(),
                ],
              ),
            ),

            // Examples section
            if (wasteType.examples.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ví dụ:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wasteType.examples.join(', '),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu() {
    // Only show menu if at least one action is available
    if (onEdit == null && onDelete == null && onManageCollectionPoints == null) {
      return Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[100],
        ),
        child: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey[600],
        ),
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      offset: Offset(0, 40),
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
          case 'view':
            onView();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, color: AppColors.primaryGreen),
              SizedBox(width: 8),
              Text('Xem chi tiết'),
            ],
          ),
        ),
        if (onEdit != null)
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, color: Colors.blue),
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
                Icon(Icons.location_on_outlined, color: Colors.purple),
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
                Icon(Icons.delete_outline, color: Colors.red),
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
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tái chế':
        return Icons.recycling;
      case 'Hữu cơ':
        return Icons.compost;
      case 'Nguy hại':
        return Icons.warning_amber_rounded;
      case 'Thường':
        return Icons.delete_outline;
      default:
        return Icons.category;
    }
  }
}
