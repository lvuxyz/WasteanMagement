// widgets/waste_type/waste_type_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_state.dart';

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
    return BlocBuilder<WasteTypeBloc, WasteTypeState>(
      builder: (context, state) {
        final isDeleting = state is WasteTypeLoading && 
                         state.isDeleting && 
                         state.deletingId == wasteType.id;
        
        final isUpdating = state is WasteTypeLoading && 
                         state.isUpdating && 
                         state.updatingId == wasteType.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              InkWell(
                onTap: isDeleting || isUpdating ? null : onView,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon container
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: wasteType.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              wasteType.icon,
                              color: wasteType.color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
    
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wasteType.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                
                                // Recyclable badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: wasteType.recyclable 
                                      ? Colors.green.withOpacity(0.1) 
                                      : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    wasteType.recyclable ? 'Tái chế được' : 'Không tái chế',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: wasteType.recyclable ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 4),
                                
                                // Price information
                                if (wasteType.unitPrice > 0)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.monetization_on_outlined,
                                        size: 14,
                                        color: Colors.orange[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${wasteType.unitPrice}đ/${wasteType.unit}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
    
                          // Menu button or loading indicator
                          if (isDeleting || isUpdating)
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDeleting ? Colors.red : Colors.blue
                                ),
                              ),
                            )
                          else if (onEdit != null || onDelete != null || onManageCollectionPoints != null)
                            _buildActionMenu(),
                        ],
                      ),
                    ),
    
                    // Description and handling instructions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wasteType.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (wasteType.handlingInstructions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      wasteType.handlingInstructions,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.blue[700],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              
              // Loading overlay when deleting
              if (isDeleting)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Đang xóa...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
              // Loading overlay when updating
              if (isUpdating)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Đang cập nhật...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildActionMenu() {
    if (onEdit == null && onDelete == null && onManageCollectionPoints == null) {
      return Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
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
