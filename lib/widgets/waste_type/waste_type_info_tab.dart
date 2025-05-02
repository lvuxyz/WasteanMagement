// widgets/waste_type/waste_type_info_tab.dart
import 'package:flutter/material.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';

class WasteTypeInfoTab extends StatelessWidget {
  final WasteType wasteType;

  const WasteTypeInfoTab({
    Key? key,
    required this.wasteType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isHazardous = wasteType.category == 'Nguy hại';
    final isRecyclable = wasteType.recyclable;
    final statusColor = isHazardous 
        ? Colors.red 
        : isRecyclable ? AppColors.primaryGreen : Colors.grey;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID and Badge section
          _buildIdAndStatusSection(isRecyclable),
          
          const SizedBox(height: 20),
          
          // Mô tả chi tiết
          _buildDescriptionSection(),
          
          const SizedBox(height: 20),
          
          // Hướng dẫn xử lý
          _buildRecyclingMethodSection(statusColor),
          
          // Thông tin thu mua nếu có
          if (wasteType.unitPrice > 0) ...[
            const SizedBox(height: 20),
            _buildPriceSection(),
          ],
          
          const SizedBox(height: 32),
          
          // Call to action
          _buildActionButton(context, isRecyclable),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildIdAndStatusSection(bool isRecyclable) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ID Card
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tag, size: 18, color: Colors.grey[700]),
                SizedBox(width: 8),
                Text(
                  'ID: ${wasteType.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(width: 12),
        
        // Recyclable status
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isRecyclable ? AppColors.primaryGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isRecyclable ? AppColors.primaryGreen.withOpacity(0.3) : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRecyclable ? Icons.recycling : Icons.do_not_disturb,
                  size: 18, 
                  color: isRecyclable ? AppColors.primaryGreen : Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  isRecyclable ? 'Có thể tái chế' : 'Không thể tái chế',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isRecyclable ? AppColors.primaryGreen : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primaryGreen),
                SizedBox(width: 8),
                Text(
                  'Mô tả chi tiết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Text(
              wasteType.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecyclingMethodSection(Color statusColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.recycling, color: statusColor),
                SizedBox(width: 8),
                Text(
                  'Hướng dẫn xử lý',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.1),
                        child: Icon(
                          wasteType.recyclable
                              ? Icons.tips_and_updates_outlined
                              : Icons.warning_amber_rounded,
                          color: statusColor,
                          size: 20,
                        ),
                        radius: 16,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          wasteType.handlingInstructions,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Thông tin thu mua',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${wasteType.unitPrice}đ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'trên mỗi ${wasteType.unit}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Hãy mang tới các điểm thu gom để bán và nhận tiền mặt!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isRecyclable) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm ${wasteType.name} vào kế hoạch tái chế của bạn'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isRecyclable ? AppColors.primaryGreen : Colors.grey,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isRecyclable ? 'Thêm vào kế hoạch tái chế' : 'Không thể tái chế',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
