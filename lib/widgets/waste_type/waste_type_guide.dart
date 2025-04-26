import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class WasteTypeGuide extends StatefulWidget {
  const WasteTypeGuide({Key? key}) : super(key: key);

  @override
  State<WasteTypeGuide> createState() => _WasteTypeGuideState();
}

class _WasteTypeGuideState extends State<WasteTypeGuide> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header phần hướng dẫn
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.eco,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hướng dẫn phân loại rác',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tìm hiểu cách phân loại rác đúng cách',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tab Bar phân loại
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryGreen,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 3,
                    color: AppColors.primaryGreen,
                  ),
                ),
                tabs: const [
                  Tab(text: 'Tái chế'),
                  Tab(text: 'Hữu cơ'),
                  Tab(text: 'Nguy hại'),
                  Tab(text: 'Thường'),
                ],
              ),
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildRecyclableTab(),
                  _buildOrganicTab(),
                  _buildHazardousTab(),
                  _buildGeneralTab(),
                ],
              ),
            ),

            // Footer với button đóng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Đã hiểu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tab Rác tái chế
  Widget _buildRecyclableTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(
            icon: Icons.recycling,
            color: Colors.blue,
            title: 'Rác tái chế',
            subtitle: 'Rửa sạch và làm khô trước khi phân loại',
          ),
          const SizedBox(height: 16),
          _buildWasteTypeItem(
            icon: Icons.local_drink_outlined,
            color: Colors.blue,
            name: 'Nhựa',
            examples: ['Chai nước', 'Túi ni-lông sạch', 'Hộp đựng thực phẩm'],
            instructions: 'Rửa sạch, làm khô và nén lại trước khi mang đi tái chế.',
          ),
          _buildWasteTypeItem(
            icon: Icons.description_outlined,
            color: Colors.amber,
            name: 'Giấy, bìa carton',
            examples: ['Báo, tạp chí', 'Hộp carton', 'Sách vở cũ'],
            instructions: 'Tháo bỏ băng keo, ghim, giữ khô ráo và xếp gọn.',
          ),
          _buildWasteTypeItem(
            icon: Icons.settings_outlined,
            color: Colors.grey,
            name: 'Kim loại',
            examples: ['Lon nước ngọt', 'Đồ hộp', 'Vật dụng kim loại nhỏ'],
            instructions: 'Rửa sạch, làm khô và nén lại nếu có thể.',
          ),
          _buildWasteTypeItem(
            icon: Icons.wine_bar_outlined,
            color: Colors.lightBlue,
            name: 'Kính, thủy tinh',
            examples: ['Chai rượu, bia', 'Lọ đựng gia vị', 'Chai mỹ phẩm'],
            instructions: 'Rửa sạch, tháo bỏ nắp kim loại và nhãn giấy.',
          ),
          const SizedBox(height: 16),
          _buildTip(
            'Quan trọng: Đảm bảo các vật liệu tái chế không bị nhiễm bẩn bởi thức ăn hoặc dầu mỡ.',
          ),
        ],
      ),
    );
  }

  // Tab Rác hữu cơ
  Widget _buildOrganicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(
            icon: Icons.compost,
            color: Colors.green,
            title: 'Rác hữu cơ',
            subtitle: 'Có thể ủ làm phân compost',
          ),
          const SizedBox(height: 16),
          _buildWasteTypeItem(
            icon: Icons.restaurant_outlined,
            color: Colors.green,
            name: 'Thực phẩm',
            examples: ['Thức ăn thừa', 'Vỏ trái cây', 'Bã cà phê'],
            instructions: 'Thu gom riêng, có thể ủ làm phân compost hoặc làm thức ăn cho vật nuôi.',
          ),
          _buildWasteTypeItem(
            icon: Icons.grass,
            color: Colors.green.shade700,
            name: 'Rác vườn',
            examples: ['Lá cây', 'Cành cây nhỏ', 'Cỏ cắt'],
            instructions: 'Có thể cắt nhỏ để ủ phân compost nhanh hơn.',
          ),
          const SizedBox(height: 16),
          _buildTip(
            'Lưu ý: Không trộn lẫn rác hữu cơ với nhựa, kim loại hoặc các chất không phân hủy.',
          ),
          const SizedBox(height: 16),
          _buildBenefits([
            'Giảm lượng rác thải phải chôn lấp',
            'Tạo ra phân bón tự nhiên cho cây trồng',
            'Giảm phát thải khí nhà kính',
          ]),
        ],
      ),
    );
  }

  // Tab Rác nguy hại
  Widget _buildHazardousTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(
            icon: Icons.warning_amber_rounded,
            color: Colors.red,
            title: 'Rác nguy hại',
            subtitle: 'Cần xử lý đặc biệt, không vứt lẫn với rác thường',
          ),
          const SizedBox(height: 16),
          _buildWasteTypeItem(
            icon: Icons.battery_alert_outlined,
            color: Colors.red,
            name: 'Pin, ắc quy',
            examples: ['Pin alkaline', 'Pin sạc', 'Ắc quy điện thoại'],
            instructions: 'Cần thu gom riêng, mang đến điểm thu gom chuyên dụng.',
          ),
          _buildWasteTypeItem(
            icon: Icons.smartphone_outlined,
            color: Colors.purple,
            name: 'Thiết bị điện tử',
            examples: ['Điện thoại cũ', 'Máy tính', 'Thiết bị điện gia dụng'],
            instructions: 'Mang đến các điểm thu mua điện tử cũ hoặc điểm tái chế chuyên dụng.',
          ),
          _buildWasteTypeItem(
            icon: Icons.invert_colors,
            color: Colors.deepOrange,
            name: 'Hóa chất',
            examples: ['Thuốc trừ sâu', 'Dung môi', 'Sơn, dầu'],
            instructions: 'Đựng trong hộp kín, không đổ xuống cống rãnh, mang đến điểm thu gom đặc biệt.',
          ),
          _buildWasteTypeItem(
            icon: Icons.medical_services_outlined,
            color: Colors.red.shade800,
            name: 'Rác y tế',
            examples: ['Thuốc hết hạn', 'Kim tiêm', 'Băng gạc y tế'],
            instructions: 'Bọc kĩ, dán nhãn rõ ràng và mang đến các điểm thu gom chuyên dụng.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.priority_high,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tuyệt đối không vứt chung rác nguy hại với rác thải thông thường. Chúng có thể gây ô nhiễm môi trường và ảnh hưởng đến sức khỏe con người.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab Rác thường
  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(
            icon: Icons.delete_outline,
            color: Colors.grey,
            title: 'Rác thường',
            subtitle: 'Rác không thể tái chế hoặc xử lý',
          ),
          const SizedBox(height: 16),
          _buildWasteTypeItem(
            icon: Icons.bubble_chart_outlined,
            color: Colors.grey,
            name: 'Rác thải hỗn hợp',
            examples: ['Tã lót', 'Băng vệ sinh', 'Bao bì nhiều lớp'],
            instructions: 'Bọc kín và vứt vào thùng rác thường.',
          ),
          _buildWasteTypeItem(
            icon: Icons.format_paint_outlined,
            color: Colors.blueGrey,
            name: 'Vật liệu khó phân hủy',
            examples: ['Xốp', 'Túi ni-lông bẩn', 'Đồ nhựa dùng một lần'],
            instructions: 'Cố gắng giảm thiểu sử dụng các vật liệu này.',
          ),
          const SizedBox(height: 16),
          _buildTip(
            'Lời khuyên: Cố gắng giảm thiểu rác thường bằng cách lựa chọn các sản phẩm có thể tái chế, tái sử dụng hoặc phân hủy sinh học.',
          ),
          const SizedBox(height: 16),
          _buildReduceTips([
            'Mang theo túi vải khi đi mua sắm',
            'Sử dụng bình nước cá nhân thay vì nước đóng chai',
            'Tránh sử dụng đồ nhựa dùng một lần',
            'Chọn mua sản phẩm có bao bì tối giản hoặc có thể tái chế',
          ]),
        ],
      ),
    );
  }

  // Widget hiển thị tiêu đề danh mục
  Widget _buildCategoryHeader({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
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

  // Widget hiển thị loại rác
  Widget _buildWasteTypeItem({
    required IconData icon,
    required Color color,
    required String name,
    required List<String> examples,
    required String instructions,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Ví dụ: ${examples.first}...',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Danh sách ví dụ
                const Text(
                  'Ví dụ:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: examples.map((example) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.fiber_manual_record,
                            size: 8,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              example,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Hướng dẫn xử lý
                const Text(
                  'Cách xử lý:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  instructions,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị lời khuyên
  Widget _buildTip(String tip) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.yellow.shade800.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.yellow.shade800,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.yellow.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị lợi ích
  Widget _buildBenefits(List<String> benefits) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lợi ích',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          ...benefits.map((benefit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefit,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Widget hiển thị mẹo giảm thiểu
  Widget _buildReduceTips(List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cách giảm thiểu rác thải',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.eco,
                    color: Colors.blue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}