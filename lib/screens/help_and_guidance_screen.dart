import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../utils/app_colors.dart';

class HelpAndGuidanceScreen extends StatefulWidget {
  const HelpAndGuidanceScreen({Key? key}) : super(key: key);

  @override
  State<HelpAndGuidanceScreen> createState() => _HelpAndGuidanceScreenState();
}

class _HelpAndGuidanceScreenState extends State<HelpAndGuidanceScreen> {
  // List of FAQ items
  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'Làm thế nào để quét mã QR trên rác thải?',
      'answer': 'Để quét mã QR trên rác thải, hãy mở ứng dụng và nhấn vào biểu tượng camera ở giữa thanh điều hướng dưới cùng. Sau đó, hướng camera vào mã QR trên bao bì hoặc nhãn sản phẩm. Ứng dụng sẽ tự động nhận diện mã QR và cung cấp thông tin về phân loại rác thải cho sản phẩm đó.',
      'isExpanded': false,
    },
    {
      'question': 'Làm thế nào để đặt lịch thu gom rác?',
      'answer': 'Để đặt lịch thu gom rác, truy cập vào tab "Đặt lịch" từ menu chính, chọn loại rác cần thu gom, nhập khối lượng ước tính, và chọn thời gian thu gom phù hợp. Sau khi xác nhận, yêu cầu của bạn sẽ được ghi nhận và hiển thị trong phần "Lịch hẹn" của ứng dụng.',
      'isExpanded': false,
    },
    {
      'question': 'Làm thế nào để tích điểm thưởng từ việc tái chế?',
      'answer': 'Mỗi khi bạn tham gia vào các hoạt động tái chế thông qua ứng dụng (như gửi rác đến điểm thu gom, hoàn thành nhiệm vụ tái chế, chia sẻ thông tin về tái chế), bạn sẽ được tích điểm thưởng tự động. Bạn có thể theo dõi số điểm thưởng của mình trong phần "Tài khoản" > "Điểm thưởng".',
      'isExpanded': false,
    },
    {
      'question': 'Làm thế nào để tìm điểm thu gom gần nhất?',
      'answer': 'Để tìm điểm thu gom gần nhất, hãy mở tab "Địa điểm" từ thanh menu dưới cùng. Ứng dụng sẽ tự động hiển thị các điểm thu gom rác gần vị trí hiện tại của bạn. Bạn có thể lọc kết quả theo loại rác cần thu gom hoặc khoảng cách.',
      'isExpanded': false,
    },
    {
      'question': 'Làm thế nào để phân loại rác thải đúng cách?',
      'answer': 'Ứng dụng cung cấp hướng dẫn chi tiết về cách phân loại rác thải trong phần "Hướng dẫn phân loại". Bạn có thể tìm kiếm theo tên sản phẩm hoặc quét mã vạch/QR để nhận thông tin phân loại chính xác. Ngoài ra, thư viện phân loại rác cũng cung cấp thông tin về các loại rác thải phổ biến và cách xử lý chúng.',
      'isExpanded': false,
    },
    {
      'question': 'Làm thế nào để đổi điểm thưởng?',
      'answer': 'Để đổi điểm thưởng, hãy truy cập vào phần "Đổi điểm" từ trang chủ hoặc từ phần "Tài khoản" > "Điểm thưởng". Tại đây, bạn sẽ thấy danh sách các phần thưởng hoặc ưu đãi mà bạn có thể đổi lấy bằng điểm thưởng của mình. Chọn phần thưởng bạn muốn và làm theo hướng dẫn để hoàn tất quá trình đổi điểm.',
      'isExpanded': false,
    },
    {
      'question': 'Làm thế nào để kiểm tra thống kê tái chế của tôi?',
      'answer': 'Bạn có thể kiểm tra thống kê tái chế của mình bằng cách truy cập vào tab "Thống kê" từ thanh menu dưới cùng. Tại đây, bạn sẽ thấy các biểu đồ và số liệu chi tiết về lượng rác thải đã tái chế theo loại, thời gian, và tác động môi trường tích cực mà bạn đã tạo ra.',
      'isExpanded': false,
    },
  ];

  // List of tutorial categories
  final List<Map<String, dynamic>> _tutorialCategories = [
    {
      'title': 'Bắt đầu sử dụng',
      'icon': Icons.play_circle_outline,
      'color': Colors.blue,
    },
    {
      'title': 'Phân loại rác',
      'icon': Icons.delete_outline,
      'color': Colors.orange,
    },
    {
      'title': 'Đặt lịch thu gom',
      'icon': Icons.calendar_today,
      'color': Colors.purple,
    },
    {
      'title': 'Tìm điểm thu gom',
      'icon': Icons.location_on_outlined,
      'color': Colors.red,
    },
    {
      'title': 'Tích & đổi điểm',
      'icon': Icons.card_giftcard,
      'color': Colors.green,
    },
    {
      'title': 'Thống kê & báo cáo',
      'icon': Icons.bar_chart,
      'color': Colors.teal,
    },
  ];

  // Search controller
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredFaqs = [];

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _faqItems;
    _searchController.addListener(_filterFaqs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFaqs() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredFaqs = _faqItems;
      } else {
        _filteredFaqs = _faqItems
            .where((faq) =>
        faq['question'].toLowerCase().contains(query) ||
            faq['answer'].toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          title: const Text(
            'Trợ giúp & Hướng dẫn',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'FAQ'),
              Tab(text: 'Hướng dẫn'),
              Tab(text: 'Liên hệ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFaqTab(),
            _buildTutorialsTab(),
            _buildContactTab(),
          ],
        ),
      ),
    );
  }

  // FAQ Tab
  Widget _buildFaqTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm câu hỏi...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 16),

          // FAQ list
          Expanded(
            child: _filteredFaqs.isEmpty
                ? const Center(
              child: Text(
                'Không tìm thấy câu hỏi nào phù hợp',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
                : ListView.builder(
              itemCount: _filteredFaqs.length,
              itemBuilder: (context, index) {
                final faq = _filteredFaqs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: faq['isExpanded'],
                    onExpansionChanged: (expanded) {
                      setState(() {
                        faq['isExpanded'] = expanded;
                      });
                    },
                    title: Text(
                      faq['question'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          faq['answer'],
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Tutorials Tab
  Widget _buildTutorialsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hướng dẫn sử dụng ứng dụng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Chọn một danh mục để xem hướng dẫn chi tiết',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),

          // Tutorial categories
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _tutorialCategories.length,
              itemBuilder: (context, index) {
                final category = _tutorialCategories[index];
                return _buildTutorialCard(
                  title: category['title'],
                  icon: category['icon'],
                  color: category['color'],
                  onTap: () {
                    // Navigate to specific tutorial screen
                    // This would be implemented to show specific tutorial content
                    _showTutorialNotImplementedDialog(category['title']);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Video tutorials section
          const Text(
            'Video hướng dẫn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Video list
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildVideoThumbnail(
                  title: 'Hướng dẫn đăng ký và đăng nhập',
                  duration: '3:24',
                  thumbnail: 'assets/video_thumb1.jpg',
                ),
                _buildVideoThumbnail(
                  title: 'Cách phân loại rác thải tại nhà',
                  duration: '5:12',
                  thumbnail: 'assets/video_thumb2.jpg',
                ),
                _buildVideoThumbnail(
                  title: 'Hướng dẫn đặt lịch thu gom',
                  duration: '2:45',
                  thumbnail: 'assets/video_thumb3.jpg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Contact Tab
  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryGreen,
              child: Icon(
                Icons.support_agent,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Bạn cần trợ giúp thêm?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Nhóm hỗ trợ của chúng tôi luôn sẵn sàng giúp đỡ bạn. Vui lòng liên hệ qua một trong các phương thức dưới đây.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Contact methods
          _buildContactMethod(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'hotro@lvurac.com',
            color: Colors.red,
            onTap: () {
              // Launch email client
            },
          ),

          _buildContactMethod(
            icon: Icons.phone_outlined,
            title: 'Điện thoại',
            value: '1900 0000',
            color: Colors.green,
            onTap: () {
              // Launch phone dialer
            },
          ),

          _buildContactMethod(
            icon: Icons.chat_bubble_outline,
            title: 'Live Chat',
            value: 'Trò chuyện với nhân viên hỗ trợ',
            color: Colors.blue,
            onTap: () {
              // Open live chat
            },
          ),

          const SizedBox(height: 30),

          // FAQ link
          GestureDetector(
            onTap: () {
              DefaultTabController.of(context).animateTo(0);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.help_outline,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Xem câu hỏi thường gặp',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Office hours
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giờ làm việc',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Thứ 2 - Thứ 6',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    const Text(
                      '8:00 - 17:30',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Thứ 7',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    const Text(
                      '8:00 - 12:00',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Chủ nhật & Ngày lễ',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    const Text(
                      'Đóng cửa',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail({
    required String title,
    required String duration,
    required String thumbnail,
  }) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video thumbnail with duration badge
          Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  color: Colors.grey[300],
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    duration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Video title
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
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
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  // This is just for UI mockup - would be integrated with actual navigation
  void _showTutorialNotImplementedDialog(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: Text('Hướng dẫn về "$category" hiện đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}