import 'package:flutter/material.dart';

class WasteTypeGuide extends StatelessWidget {
  const WasteTypeGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hướng dẫn phân loại rác'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGuideSection(
              'Rác tái chế',
              Colors.green,
              'Rửa sạch và làm khô trước khi phân loại. Gồm: nhựa, giấy, kim loại, thủy tinh...',
            ),
            const SizedBox(height: 16),
            _buildGuideSection(
              'Rác hữu cơ',
              Colors.green,
              'Thức ăn thừa, vỏ trái cây, rau củ. Có thể ủ làm phân compost.',
            ),
            const SizedBox(height: 16),
            _buildGuideSection(
              'Rác nguy hại',
              Colors.red,
              'Pin, thiết bị điện tử, hóa chất... Cần thu gom riêng và xử lý đặc biệt.',
            ),
            const SizedBox(height: 16),
            _buildGuideSection(
              'Rác thường',
              Colors.grey,
              'Rác không thể tái chế hoặc xử lý. Cần hạn chế tối đa loại rác này.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  Widget _buildGuideSection(String title, Color color, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}