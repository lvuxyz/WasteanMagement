import 'package:flutter/material.dart';
import '../../models/recycling_record_model.dart';
import 'package:intl/intl.dart';

class RecyclingRecordItem extends StatelessWidget {
  final RecyclingRecord record;
  
  const RecyclingRecordItem({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final Color statusColor = record.isVerified ? Colors.green : Colors.orange;
    final String statusText = record.isVerified ? 'Đã xác nhận' : 'Chờ xác nhận';
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon based on waste type
                _buildWasteTypeIcon(),
                
                const SizedBox(width: 12),
                
                // Waste type and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.wasteTypeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ngày: ${dateFormat.format(record.date)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: statusColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(
                  'Khối lượng',
                  '${record.weight} kg',
                  Icons.scale,
                ),
                _buildDetailItem(
                  'Địa điểm',
                  record.collectionPointName,
                  Icons.location_on,
                ),
                _buildDetailItem(
                  'Điểm thưởng',
                  '${record.rewardPoints ?? 0}',
                  Icons.stars,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWasteTypeIcon() {
    IconData iconData;
    Color iconColor;
    
    // Choose icon based on waste type category
    switch (record.wasteTypeCategory.toLowerCase()) {
      case 'giấy và carton':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'nhựa':
        iconData = Icons.local_drink;
        iconColor = Colors.green;
        break;
      case 'kim loại':
        iconData = Icons.shopping_basket;
        iconColor = Colors.grey;
        break;
      case 'thủy tinh':
        iconData = Icons.wine_bar;
        iconColor = Colors.amber;
        break;
      default:
        iconData = Icons.delete_outline;
        iconColor = Colors.teal;
    }
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }
  
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.grey.shade600,
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
} 