import 'package:flutter/material.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';

class WasteTypeCard extends StatelessWidget {
  final WasteType wasteType;
  final VoidCallback onTap;

  const WasteTypeCard({
    Key? key,
    required this.wasteType,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Xác định màu sắc dựa trên loại rác
    final Color cardColor = wasteType.category == 'Nguy hại'
        ? Colors.red.withOpacity(0.05)
        : Colors.white;

    // Xác định biểu tượng trạng thái
    final bool isRecyclable = wasteType.category == 'Tái chế';
    final IconData statusIcon = isRecyclable
        ? Icons.recycling
        : Icons.warning_amber_rounded;
    final Color statusColor = isRecyclable
        ? AppColors.primaryGreen
        : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: wasteType.category == 'Nguy hại'
              ? Colors.red.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: wasteType.color.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Phần trên của card
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Biểu tượng của loại rác
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: wasteType.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: wasteType.color.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
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

                    // Thông tin của loại rác
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  wasteType.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                statusIcon,
                                color: statusColor,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Mô tả ngắn về loại rác
                          Text(
                            wasteType.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Hiển thị tag phân loại sử dụng Wrap thay vì Row để tránh overflow
                          Wrap(
                            spacing: 8, // Khoảng cách giữa các phần tử theo chiều ngang
                            runSpacing: 8, // Khoảng cách giữa các dòng khi xuống dòng
                            children: [
                              // Tag loại rác (ưu tiên hiển thị)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: wasteType.category == 'Nguy hại'
                                      ? Colors.red.withOpacity(0.1)
                                      : AppColors.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  wasteType.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: wasteType.category == 'Nguy hại'
                                        ? Colors.red
                                        : AppColors.primaryGreen,
                                  ),
                                ),
                              ),

                              // Hiển thị điểm thưởng (ưu tiên thứ hai)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.emoji_events_outlined,
                                      color: Colors.purple,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${_extractPoints(wasteType.recentPoints)} đ',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Giá thu mua (nếu có và nếu còn chỗ)
                              if (wasteType.buyingPrice > 0)
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
                          ),
                        ],
                      ),
                    ),

                    // Biểu tượng mũi tên để hiển thị chi tiết
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Phần dưới của card (có thể thêm các ví dụ ngắn)
              if (wasteType.examples.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ví dụ:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wasteType.examples.first,
                        style: TextStyle(
                          fontSize: 12,
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
      ),
    );
  }

  // Hàm trích xuất số điểm từ chuỗi "Tái chế 1kg nhựa = 5 điểm"
  int _extractPoints(String pointsText) {
    // Tìm số điểm trong chuỗi
    RegExp regex = RegExp(r'(\d+)\s+điểm');
    Match? match = regex.firstMatch(pointsText);
    if (match != null && match.groupCount >= 1) {
      return int.parse(match.group(1)!);
    }
    return 0;
  }
}