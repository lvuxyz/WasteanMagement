import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_event.dart';
import '../blocs/language/language_state.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/custom_button.dart';
import '../screens/language_selection_screen.dart';
import '../screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Các thống kê người dùng
  final double _totalWaste = 32.5; // kg
  final int _totalPoints = 450;
  final int _activeDays = 14;
  final int _completedGoals = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(
        title: l10n.profile,
        backgroundColor: AppColors.primaryGreen,
        titleColor: Colors.white,
        iconColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              _showSettingsBottomSheet(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildStatisticsSection(),
            const SizedBox(height: 16),
            _buildOptionsSection(context),
          ],
        ),
      ),
    );
  }

  // Widget thông tin người dùng
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              widget.username.isNotEmpty ? widget.username[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Thành viên kể từ Tháng 3, 2023',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Người bảo vệ môi trường',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget thống kê hoạt động người dùng
  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Thống kê của bạn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.delete_outline,
                value: '${_totalWaste.toStringAsFixed(1)} kg',
                label: 'Rác đã phân loại',
              ),
              _buildStatItem(
                icon: Icons.stars,
                value: '$_totalPoints',
                label: 'Điểm tích lũy',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.calendar_today,
                value: '$_activeDays ngày',
                label: 'Hoạt động liên tục',
              ),
              _buildStatItem(
                icon: Icons.flag,
                value: '$_completedGoals',
                label: 'Mục tiêu đã hoàn thành',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget item thống kê
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget phần tùy chọn
  Widget _buildOptionsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Cài đặt tài khoản',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildOptionItem(
            icon: Icons.person_outline,
            title: 'Chỉnh sửa thông tin cá nhân',
            onTap: () {
              // TODO: Điều hướng đến màn hình chỉnh sửa thông tin
            },
          ),
          _buildOptionItem(
            icon: Icons.lock_outline,
            title: 'Thay đổi mật khẩu',
            onTap: () {
              // TODO: Điều hướng đến màn hình đổi mật khẩu
            },
          ),
          _buildOptionItem(
            icon: Icons.language,
            title: 'Thay đổi ngôn ngữ',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSelectionScreen(),
                ),
              );
            },
          ),
          _buildOptionItem(
            icon: Icons.notifications_outlined,
            title: 'Cài đặt thông báo',
            onTap: () {
              // TODO: Điều hướng đến màn hình cài đặt thông báo
            },
          ),
          _buildOptionItem(
            icon: Icons.help_outline,
            title: 'Trợ giúp & Hướng dẫn',
            onTap: () {
              // TODO: Điều hướng đến màn hình trợ giúp
            },
          ),
          _buildOptionItem(
            icon: Icons.info_outline,
            title: 'Về ứng dụng',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CustomButton(
              text: l10n.logout,
              backgroundColor: Colors.red,
              onPressed: () {
                _confirmLogout(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget item tùy chọn
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGreen),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.secondaryText,
        ),
        onTap: onTap,
      ),
    );
  }

  // Dialog xác nhận đăng xuất
  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.read<AuthBloc>().add(LogoutEvent());

      // Điều hướng về màn hình đăng nhập
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  // Bottom sheet cài đặt
  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cài đặt hiển thị',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Chế độ tối'),
              trailing: Switch(
                value: false, // TODO: Lấy giá trị từ theme provider
                onChanged: (value) {
                  // TODO: Cập nhật theme
                  Navigator.pop(context);
                },
                activeColor: AppColors.primaryGreen,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: const Text('Thay đổi ngôn ngữ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSelectionScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.font_download),
              title: const Text('Kích thước chữ'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Mở dialog chọn cỡ chữ
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dialog về ứng dụng
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về ứng dụng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LVuRác - Ứng dụng Quản lý Chất thải và Tái chế',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Phiên bản: 1.0.0'),
            const SizedBox(height: 8),
            const Text(
              'Ứng dụng giúp bạn phân loại, quản lý rác thải và đóng góp vào hoạt động bảo vệ môi trường.',
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2023 LVuRác - All Rights Reserved',
              style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
          ],
        ),
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