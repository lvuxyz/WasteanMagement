import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../utils/app_colors.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_menu_item.dart';
import '../screens/login_screen.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          title: const Text('Thông tin cá nhân'),
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const ProfileHeader(
                avatarUrl: 'assets/images/avatar.png',
                fullName: 'Minh Nguyễn',
                email: 'minh@demo.com',
              ),
              const SizedBox(height: 20),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ProfileMenuItem(
                      icon: Icons.person,
                      title: 'Thông tin tài khoản',
                      onTap: () {
                        // Xử lý khi người dùng nhấn vào thông tin tài khoản
                      },
                    ),
                    const Divider(height: 1),
                    ProfileMenuItem(
                      icon: Icons.settings,
                      title: 'Cài đặt',
                      onTap: () {
                        // Xử lý khi người dùng nhấn vào cài đặt
                      },
                    ),
                    const Divider(height: 1),
                    ProfileMenuItem(
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
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ProfileMenuItem(
                      icon: Icons.help,
                      title: 'Trợ giúp & Hỗ trợ',
                      onTap: () {
                        // Xử lý khi người dùng nhấn vào trợ giúp & hỗ trợ
                      },
                    ),
                    const Divider(height: 1),
                    ProfileMenuItem(
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
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  textColor: AppColors.errorRed,
                  iconColor: AppColors.errorRed,
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
                              backgroundColor: AppColors.errorRed,
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
}