import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../l10n/app_localizations.dart';
import '../repositories/user_repository.dart';
import '../routes.dart';
import '../utils/app_colors.dart';
import '../utils/app_logger.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Lấy UserRepository
    final userRepository = context.read<UserRepository>();

    // TÙY CHỌN: Tắt dòng này khi phát hành, chỉ dùng khi phát triển
    // Xóa token cũ để luôn phải đăng nhập lại khi debug
    // await userRepository.logout();
    // AppLogger.d('Welcome', 'Đã xóa token cũ (chỉ ở chế độ debug)');

    final isLogged = await userRepository.isLoggedIn();

    AppLogger.d('Welcome', 'Trạng thái đăng nhập: ${isLogged ? "Đã đăng nhập" : "Chưa đăng nhập"}');

    // Chỉ kiểm tra nếu có token
    if (isLogged) {
      try {
        // Kiểm tra token có hợp lệ không
        await userRepository.getUserProfile();

        // Thêm độ trễ nhỏ để hiển thị splash screen
        await Future.delayed(const Duration(milliseconds: 1500));

        // Điều hướng đến màn hình chính nếu đã đăng nhập
        if (mounted && context.read<AuthBloc>().state is Authenticated) {
          AppLogger.d('Welcome', 'Token hợp lệ, chuyển hướng đến màn hình chính');
          Navigator.of(context).pushReplacementNamed(AppRoutes.main);
          return;
        }
      } catch (e) {
        AppLogger.e('Welcome', 'Token không hợp lệ hoặc lỗi', error: e);
        // Đăng xuất nếu token không hợp lệ
        await userRepository.logout();
      }
    }

    // Thêm độ trễ nhỏ để hiển thị splash screen
    await Future.delayed(const Duration(milliseconds: 1500));

    // Nếu không có token hoặc token không hợp lệ, điều hướng đến màn hình đăng nhập
    if (mounted) {
      AppLogger.d('Welcome', 'Chuyển hướng đến màn hình đăng nhập');
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(75),
                  ),
                  child: const Icon(
                    Icons.recycling,
                    size: 80,
                    color: AppColors.primaryGreen,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // App name
            Text(
              l10n.welcomeTitle,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            // App slogan
            Text(
              l10n.welcomeSubtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 50),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

