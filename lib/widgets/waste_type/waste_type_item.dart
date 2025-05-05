import 'package:flutter/material.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';

class WasteTypeItem extends StatelessWidget {
  final WasteType wasteType;
  final VoidCallback? onTap;

  const WasteTypeItem({
    Key? key,
    required this.wasteType,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getTypeColor(wasteType.recyclable).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getTypeIcon(wasteType.recyclable),
                      color: _getTypeColor(wasteType.recyclable),
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
                        
                        // Price information
                        if (wasteType.unitPrice > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.monetization_on_outlined,
                                  size: 14,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${wasteType.unitPrice}đ/kg',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.orange[700],
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

              // Description
              if (wasteType.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    wasteType.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Handling instructions
              if (wasteType.handlingInstructions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(bool recyclable) {
    return recyclable ? Icons.recycling : Icons.delete_outline;
  }

  Color _getTypeColor(bool recyclable) {
    return recyclable ? AppColors.primaryGreen : Colors.grey;
  }
} 