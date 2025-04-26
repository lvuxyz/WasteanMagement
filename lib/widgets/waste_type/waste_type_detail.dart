import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';

class WasteTypeDetail extends StatelessWidget {
  final WasteType wasteType;

  const WasteTypeDetail({
    Key? key,
    required this.wasteType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isHazardous = wasteType.category == 'Nguy hại';
    final statusColor = isHazardous ? Colors.red : AppColors.primaryGreen;
    final statusText = isHazardous ? 'Nguy hại' : 'Có thể tái chế';
    final statusIcon = isHazardous ? Icons.warning_amber_rounded : Icons.recycling;

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Thanh kéo ở đầu màn hình
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Phần nội dung có thể cuộn
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần header với thông tin cơ bản
                  _buildHeader(statusColor, statusText, statusIcon),

                  // Mô tả
                  const SizedBox(height: 24),
                  _buildSectionTitle('Mô tả'),
                  const SizedBox(height: 8),
                  Text(
                    wasteType.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),

                  // Cách phân loại và xử lý
                  const SizedBox(height: 24),
                  _buildSectionTitle('Cách phân loại và xử lý'),
                  const SizedBox(height: 8),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: statusColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hướng dẫn xử lý',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          wasteType.recyclingMethod,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ví dụ
                  const SizedBox(height: 24),
                  _buildSectionTitle('Ví dụ'),
                  const SizedBox(height: 8),
                  _buildExamplesList(),

                  // Thông tin giá thu mua (nếu có)
                  if (wasteType.buyingPrice > 0) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Giá thu mua'),
                    const SizedBox(height: 8),
                    _buildPriceSection(),
                  ],

                  // Điểm thưởng
                  const SizedBox(height: 24),
                  _buildSectionTitle('Điểm thưởng'),
                  const SizedBox(height: 8),
                  _buildPointsSection(),

                  // Gợi ý cách giảm thiểu
                  const SizedBox(height: 24),
                  _buildSectionTitle('Gợi ý giảm thiểu'),
                  const SizedBox(height: 8),
                  _buildReduceTips(),

                  const SizedBox(height: 32),

                  // Nút thêm vào kế hoạch tái chế
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<WasteTypeBloc>().add(AddToRecyclingPlan(wasteType.id));
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 22),
                      label: const Text(
                        'Thêm vào kế hoạch tái chế',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị tiêu đề phần
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Widget hiển thị header
  Widget _buildHeader(Color statusColor, String statusText, IconData statusIcon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Biểu tượng loại rác
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: wasteType.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                wasteType.icon,
                color: wasteType.color,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),

            // Tên và trạng thái
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wasteType.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              color: statusColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          wasteType.category,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
      ],
    );
  }

  // Widget hiển thị danh sách ví dụ
  Widget _buildExamplesList() {
    return Column(
      children: wasteType.examples.map((example) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.primaryGreen,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  example,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Widget hiển thị thông tin giá
  Widget _buildPriceSection() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Giá hiện tại:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${wasteType.buyingPrice} đồng/${wasteType.unit}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Giá có thể thay đổi tùy theo thời điểm và điểm thu mua',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget hiển thị thông tin điểm thưởng
  Widget _buildPointsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.purple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wasteType.recentPoints,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tích điểm và đổi quà khi tham gia phân loại rác',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị gợi ý giảm thiểu
  Widget _buildReduceTips() {
    // Danh sách các gợi ý tùy theo loại rác
    final List<String> tips = wasteType.category == 'Tái chế'
        ? [
      'Sử dụng túi vải thay cho túi ni-lông',
      'Mang theo bình nước cá nhân thay vì mua nước đóng chai',
      'Tái sử dụng các hộp đựng thực phẩm',
      'Mua các sản phẩm không có bao bì hoặc bao bì tối thiểu',
    ]
        : [
      'Tránh sử dụng các sản phẩm chứa hóa chất độc hại',
      'Sử dụng pin sạc thay vì pin dùng một lần',
      'Mang thiết bị điện tử cũ đến điểm thu gom chuyên dụng',
      'Sử dụng sản phẩm làm sạch tự nhiên thay vì hóa chất',
    ];

    return Column(
      children: tips.map((tip) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.eco,
                color: AppColors.primaryGreen,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}