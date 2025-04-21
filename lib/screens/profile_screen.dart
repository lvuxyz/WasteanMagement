import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'login_screen.dart';
=======
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
// import '../blocs/auth/auth_state.dart';
// import '../blocs/language/language_bloc.dart';
// import '../blocs/language/language_event.dart';
// import '../blocs/language/language_state.dart';
import '../utils/app_colors.dart';
import '../screens/language_selection_screen.dart';
import '../screens/login_screen.dart';
>>>>>>> bugfix/languageSelection

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
<<<<<<< HEAD
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Lắng nghe trạng thái đăng xuất thành công và chuyển hướng về màn hình đăng nhập
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Thông tin cá nhân'),
          backgroundColor: Colors.green,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                color: Colors.green,
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 24.0,
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 60, color: Colors.green),
                      ),
                    ),

                    // User info
                    const Text(
                      'Minh Nguyễn',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'minh@demo.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Account settings
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person,
                      title: 'Thông tin tài khoản',
                      onTap: () {
                        // Xử lý khi người dùng nhấn vào thông tin tài khoản
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.settings,
                      title: 'Cài đặt',
                      onTap: () {
                        // Xử lý khi người dùng nhấn vào cài đặt
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.notifications,
                      title: 'Thông báo',
                      onTap: () {
                        // Xử lý khi người dùng nhấn vào thông báo
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Support and about
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.help,
                      title: 'Trợ giúp & Hỗ trợ',
                      onTap: () {
                        // Xử lý khi người dùng nhấn vào trợ giúp & hỗ trợ
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.info,
                      title: 'Về chúng tôi',
                      onTap: () {
                        // Xử lý khi người dùng nhấn vào về chúng tôi
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logout
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    // Hiển thị hộp thoại xác nhận đăng xuất
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận đăng xuất'),
                        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Đóng hộp thoại
                              // Gọi sự kiện đăng xuất
                              context.read<AuthBloc>().add(LogoutEvent());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build menu items
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.green,
    Color textColor = Colors.black87,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.withOpacity(0.6),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
=======
    final l10n = AppLocalizations.of(context);

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
>>>>>>> bugfix/languageSelection
}