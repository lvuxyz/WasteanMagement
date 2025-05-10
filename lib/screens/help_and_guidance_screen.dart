import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/help_guidance/help_guidance_bloc.dart';
import '../blocs/help_guidance/help_guidance_event.dart';
import '../blocs/help_guidance/help_guidance_state.dart';
import '../utils/app_colors.dart';

class HelpAndGuidanceScreen extends StatelessWidget {
  const HelpAndGuidanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HelpGuidanceBloc()..add(LoadHelpGuidanceData()),
      child: DefaultTabController(
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
              _FaqTab(),
              _TutorialsTab(),
              _ContactTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTab extends StatelessWidget {
  _FaqTab();

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Add listener to update search
    _searchController.addListener(() {
      context.read<HelpGuidanceBloc>().add(SearchFaqs(_searchController.text));
    });

    return BlocBuilder<HelpGuidanceBloc, HelpGuidanceState>(
      builder: (context, state) {
        // Show loading state or initial state
        if (state is! HelpGuidanceLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

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
                child: state.filteredFaqs.isEmpty
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
                        itemCount: state.filteredFaqs.length,
                        itemBuilder: (context, index) {
                          final faq = state.filteredFaqs[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: faq['isExpanded'],
                              onExpansionChanged: (expanded) {
                                // Instead of setState - update in BLoC if needed 
                                // We could add an event here if needed to track expanded state
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
      },
    );
  }
}

class _TutorialsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HelpGuidanceBloc, HelpGuidanceState>(
      builder: (context, state) {
        if (state is! HelpGuidanceLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

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
                  itemCount: state.tutorialCategories.length,
                  itemBuilder: (context, index) {
                    final category = state.tutorialCategories[index];
                    return _buildTutorialCard(
                      context: context,
                      title: category['title'],
                      icon: category['icon'],
                      color: category['color'],
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
      },
    );
  }

  Widget _buildTutorialCard({
    required BuildContext context,
    required String title,
    required String icon,
    required String color,
  }) {
    Color cardColor;
    IconData iconData;

    // Convert string color to Color
    switch (color) {
      case 'blue':
        cardColor = Colors.blue;
        break;
      case 'orange':
        cardColor = Colors.orange;
        break;
      case 'purple':
        cardColor = Colors.purple;
        break;
      case 'red':
        cardColor = Colors.red;
        break;
      case 'green':
        cardColor = AppColors.primaryGreen;
        break;
      case 'teal':
        cardColor = Colors.teal;
        break;
      default:
        cardColor = Colors.grey;
    }

    // Convert string icon to IconData
    switch (icon) {
      case 'play_circle_outline':
        iconData = Icons.play_circle_outline;
        break;
      case 'delete_outline':
        iconData = Icons.delete_outline;
        break;
      case 'calendar_today':
        iconData = Icons.calendar_today;
        break;
      case 'location_on_outlined':
        iconData = Icons.location_on_outlined;
        break;
      case 'card_giftcard':
        iconData = Icons.card_giftcard;
        break;
      case 'bar_chart':
        iconData = Icons.bar_chart;
        break;
      default:
        iconData = Icons.help_outline;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Show tutorial not implemented dialog
          _showTutorialNotImplementedDialog(context, title);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                size: 48,
                color: cardColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                // Thumbnail image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                // Duration badge
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
            ),
          ),
        ],
      ),
    );
  }

  void _showTutorialNotImplementedDialog(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hướng dẫn: $category'),
        content: const Text('Nội dung hướng dẫn chi tiết đang được xây dựng.'),
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

class _ContactTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            value: 'lvu.byte@gmail.com',
            color: Colors.red,
            onTap: () {
              // Launch email client
            },
          ),

          _buildContactMethod(
            icon: Icons.phone_outlined,
            title: 'Điện thoại',
            value: '0332265689',
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
              children: const [
                Text(
                  'Giờ làm việc',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Thứ 2 - Thứ 6: 9:00 - 17:00',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Thứ 7: 9:00 - 12:00',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Chủ nhật: Nghỉ',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
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
    return GestureDetector(
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
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
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
    );
  }
}