import 'package:flutter/material.dart';
import '../../models/waste_detection_model.dart';
import '../../utils/app_colors.dart';

class DetectionResultCard extends StatelessWidget {
  final WasteDetectionResult result;
  final VoidCallback onSave;
  final VoidCallback onRetry;

  const DetectionResultCard({
    Key? key,
    required this.result,
    required this.onSave,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Row(
              children: [
                Icon(
                  result.isRecyclable 
                    ? Icons.check_circle 
                    : Icons.info,
                  color: result.isRecyclable 
                    ? AppColors.primaryGreen 
                    : AppColors.warningYellow,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kết quả phân tích',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                Text(
                  '${result.confidence?.toStringAsFixed(1) ?? 0}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getConfidenceColor(),
                  ),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Loại rác phát hiện được
            if (result.detectedWaste != null) ...[
              _buildInfoRow(
                label: 'Loại rác:', 
                value: result.detectedWaste!.name,
                icon: Icons.category,
              ),
              
              const SizedBox(height: 12),
              
              _buildInfoRow(
                label: 'Mô tả:', 
                value: result.detectedWaste!.description,
                icon: Icons.description,
              ),
              
              const SizedBox(height: 12),
              
              _buildInfoRow(
                label: 'Có thể tái chế:', 
                value: result.isRecyclable ? 'Có' : 'Không',
                icon: Icons.recycling,
                valueColor: result.isRecyclable 
                  ? AppColors.primaryGreen 
                  : AppColors.errorRed,
              ),
              
              const SizedBox(height: 16),
              
              // Hướng dẫn xử lý
              Text(
                'Hướng dẫn xử lý:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.handlingInstructions,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondaryText,
                    side: BorderSide(color: AppColors.disabledGrey),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: result.isReliableDetection ? onSave : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Lưu kết quả'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.secondaryText,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.primaryText,
            ),
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor() {
    final confidence = result.confidence ?? 0;
    if (confidence >= 90) {
      return AppColors.primaryGreen;
    } else if (confidence >= 70) {
      return AppColors.lightGreen;
    } else if (confidence >= 50) {
      return AppColors.warningYellow;
    } else {
      return AppColors.errorRed;
    }
  }
} 