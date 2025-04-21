import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../generated/l10n.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
// import '../blocs/auth/auth_state.dart';
// import '../blocs/language/language_bloc.dart';
// import '../blocs/language/language_event.dart';
// import '../blocs/language/language_state.dart';
import '../utils/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.profile,
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(),
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


  // Widget phần tùy chọn
  Widget _buildOptionsSection(BuildContext context) {
    final l10n = S.of(context);

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
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.red,
                ),
                onTap: () => confirmLogout(),
              ),
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
  void confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // Sử dụng BlocProvider.of thay vì context.read
      BlocProvider.of<AuthBloc>(context, listen: false).add(LogoutEvent());

      // Hoặc cách khác, kiểm tra xem Provider có tồn tại không
      try {
        context.read<AuthBloc>().add(LogoutEvent());

        // Điều hướng sau khi đăng xuất
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      } catch (e) {
        // Xử lý trường hợp không tìm thấy Provider
        print('Không thể tìm thấy AuthBloc: $e');

        // Vẫn điều hướng về màn hình đăng nhập trong trường hợp lỗi
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
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

