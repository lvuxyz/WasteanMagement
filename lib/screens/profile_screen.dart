import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/blocs/auth/auth_bloc.dart';
import 'package:wasteanmagement/blocs/auth/auth_event.dart';
import 'package:wasteanmagement/blocs/auth/auth_state.dart';
import 'package:wasteanmagement/blocs/profile/profile_bloc.dart';
import 'package:wasteanmagement/blocs/profile/profile_state.dart';
import 'package:wasteanmagement/screens/change_password.dart';
import 'package:wasteanmagement/screens/help_and_guidance_screen.dart';
import 'package:wasteanmagement/screens/about_app_screen.dart';
import 'package:wasteanmagement/screens/language_selection_screen.dart';
import 'package:wasteanmagement/screens/login_screen.dart';
import 'package:wasteanmagement/screens/view_profile_screen.dart';
import 'package:wasteanmagement/utils/secure_storage.dart';
import 'package:wasteanmagement/repositories/user_repository.dart';
import '../generated/l10n.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? username;

  const ProfileScreen({
    Key? key,
    this.username,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          automaticallyImplyLeading: false,
          title: Text(
            l10n.profile,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              // Kiểm tra xem lỗi có phải do xác thực không
              if (state.message.contains("Nguoi dung chua dang nhap") ||
                  state.message.contains("token")||
                  state.message.contains("xac thuc")||
                  state.message.contains("không hợp lệ")) {
                context.read<AuthBloc>().add(CheckAuthenticationStatus());
              }else{
                  // Hiển thị thông báo cho các lỗi khác
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  ),
                  );
                  }
              }
            },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 16),
                _buildOptionsSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String userName = widget.username ?? '';
        String userEmail = '';
        String memberSince = 'Thành viên kể từ Tháng 3, 2023';

        if (state is ProfileLoaded) {
          userName = state.userProfile.basicInfo.fullName;
          userEmail = state.userProfile.basicInfo.email;
        }

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
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userEmail.isNotEmpty ? userEmail : memberSince,
                style: const TextStyle(
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
      },
    );
  }

  Widget _buildOptionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Cài đặt tài khoản',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildOptionItem(
            icon: Icons.person,
            title: 'Thông tin cá nhân',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewProfileScreen()),
              );
            },
          ),
          _buildOptionItem(
            icon: Icons.lock,
            title: 'Đổi mật khẩu',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          _buildOptionItem(
            icon: Icons.language,
            title: 'Ngôn ngữ',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
              );
            },
          ),
          
          FutureBuilder<bool>(
            future: AuthService().isAdmin(),
            builder: (context, snapshot) {
              final isAdmin = snapshot.data ?? false;
              
              if (isAdmin) {
                return Column(
                  children: [
                    const Divider(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Quản trị viên',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionItem(
                      icon: Icons.stars,
                      title: 'Quản lý điểm thưởng',
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/rewards');
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.add_circle,
                      title: 'Thêm điểm thưởng thủ công',
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/rewards/add');
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.dashboard_customize,
                      title: 'Quản lý loại rác',
                      onTap: () {
                        Navigator.pushNamed(context, '/waste-type');
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.list_alt,
                      title: 'Quản lý giao dịch',
                      onTap: () {
                        Navigator.pushNamed(context, '/transactions');
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.location_on,
                      title: 'Quản lý điểm thu gom',
                      onTap: () {
                        Navigator.pushNamed(context, '/collection-points');
                      },
                    ),
                  ],
                );
              }
              
              return const SizedBox.shrink();
            },
          ),
          
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Hỗ trợ & Thông tin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildOptionItem(
            icon: Icons.notifications,
            title: 'Thông báo',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng thông báo đang được phát triển'),
                ),
              );
            },
          ),
          _buildOptionItem(
            icon: Icons.help,
            title: 'Trợ giúp & Hướng dẫn',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpAndGuidanceScreen()),
              );
            },
          ),
          _buildOptionItem(
            icon: Icons.info,
            title: 'Giới thiệu ứng dụng',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAppScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      context.read<AuthBloc>().add(LogoutRequested());

      // Closing the loading manually is now handled by AuthBloc listener
    }
  }

  // FUNCTION NÀY CHỈ DÙNG ĐỂ DEBUG - XÓA KHI RELEASE
  Future<void> _showTokenInfo(BuildContext context) async {
    final secureStorage = SecureStorage();
    final userRepository = context.read<UserRepository>();
    
    // Lấy token
    String? token = await secureStorage.getToken();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin token (Debug)'),
        content: token != null 
          ? SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Token hiện tại:'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      token,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          : const Text('Không có token'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          if (token != null)
            TextButton(
              onPressed: () async {
                await userRepository.logout();
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa token'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // Chuyển về màn hình đăng nhập
                  context.read<AuthBloc>().add(LogoutRequested());
                }
              },
              child: const Text('Xóa Token', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final l10n = S.of(context);

    return Padding(
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
          onTap: confirmLogout,
        ),
      ),
    );
  }
}
