import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../generated/l10n.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: const Text(
          'Về ứng dụng',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAppHeader(),
            _buildAppInfo(context),
            const Divider(),
            _buildDeveloperInfo(),
            const Divider(),
            _buildAppFeatures(),
            const Divider(),
            _buildLegalInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppColors.primaryGreen,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.delete_outline,
                size: 60,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'LVuRác',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Phiên bản ${AppConstants.appVersion}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ứng dụng Quản lý Chất thải và Tái chế',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin ứng dụng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.info_outline,
            title: 'Tên ứng dụng',
            value: 'LVuRác',
          ),
          _buildInfoRow(
            icon: Icons.tag,
            title: 'Phiên bản',
            value: AppConstants.appVersion,
          ),
          _buildInfoRow(
            icon: Icons.update,
            title: 'Cập nhật gần nhất',
            value: '15/05/2023',
          ),
          _buildInfoRow(
            icon: Icons.language,
            title: 'Ngôn ngữ hỗ trợ',
            value: 'Tiếng Việt, Tiếng Anh',
          ),
          _buildInfoRow(
            icon: Icons.devices,
            title: 'Thiết bị hỗ trợ',
            value: 'Android, iOS',
          ),
          _buildInfoRow(
            icon: Icons.download,
            title: 'Kích thước',
            value: '24.5 MB',
          ),
          const SizedBox(height: 16),
          const Text(
            'LVuRác là ứng dụng quản lý chất thải và tái chế giúp người dùng dễ dàng phân loại rác thải, tìm kiếm các điểm thu gom, đặt lịch thu gom rác và tích lũy điểm thưởng từ các hoạt động tái chế. Ứng dụng hướng đến mục tiêu xây dựng một cộng đồng sống xanh và thân thiện với môi trường.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin nhà phát triển',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.business,
            title: 'Công ty',
            value: 'Công ty TNHH LVuRác Việt Nam',
          ),
          _buildInfoRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'info@lvurac.com',
          ),
          _buildInfoRow(
            icon: Icons.language,
            title: 'Website',
            value: 'www.lvurac.com',
          ),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Địa chỉ',
            value: 'Quận 1, TP. Hồ Chí Minh, Việt Nam',
          ),
        ],
      ),
    );
  }

  Widget _buildAppFeatures() {
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.qr_code_scanner,
        'title': 'Quét mã QR',
        'description': 'Quét mã QR trên sản phẩm để biết cách phân loại',
      },
      {
        'icon': Icons.sort,
        'title': 'Phân loại rác',
        'description': 'Hướng dẫn chi tiết cách phân loại rác thải',
      },
      {
        'icon': Icons.map,
        'title': 'Bản đồ điểm thu gom',
        'description': 'Tìm kiếm các điểm thu gom rác gần nhất',
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Đặt lịch thu gom',
        'description': 'Đặt lịch thu gom rác tại nhà thuận tiện',
      },
      {
        'icon': Icons.emoji_events,
        'title': 'Tích điểm thưởng',
        'description': 'Tích điểm từ hoạt động tái chế và đổi quà',
      },
      {
        'icon': Icons.insert_chart,
        'title': 'Theo dõi thống kê',
        'description': 'Xem thống kê về lượng rác đã tái chế',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tính năng chính',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'],
                      color: AppColors.primaryGreen,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegalInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin pháp lý',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // Navigate to terms & conditions screen
              _showNotImplementedDialog(context, 'Điều khoản sử dụng');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Điều khoản sử dụng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
          const Divider(height: 1),
          GestureDetector(
            onTap: () {
              // Navigate to privacy policy screen
              _showNotImplementedDialog(context, 'Chính sách bảo mật');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Chính sách bảo mật',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
          const Divider(height: 1),
          GestureDetector(
            onTap: () {
              // Navigate to licenses screen
              _showNotImplementedDialog(context, 'Giấy phép mã nguồn mở');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.source_outlined,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Giấy phép mã nguồn mở',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
          const SizedBox(height: 30),

          // Copyright info
          const Center(
            child: Text(
              '© 2023 LVuRác. Bản quyền thuộc về Công ty TNHH LVuRác Việt Nam.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Social media links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.facebook, Colors.blue),
              _buildSocialIcon(Icons.mail, Colors.red),
              _buildSocialIcon(Icons.messenger, Colors.blue),
              _buildSocialIcon(Icons.phone, Colors.green),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }

  // This is just for UI mockup - would be replaced with actual navigation
  void _showNotImplementedDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: Text('Tính năng "$feature" đang được phát triển.'),
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