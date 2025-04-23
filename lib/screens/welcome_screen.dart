import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../generated/l10n.dart';
import '../repositories/user_repository.dart';
import '../routes.dart';
import '../utils/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

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
    developer.log('Kiểm tra trạng thái xác thực');
    
    // Lấy UserRepository
    final userRepository = context.read<UserRepository>();
    
    // TÙY CHỌN: Tắt dòng này khi phát hành, chỉ dùng khi phát triển
    // Xóa token cũ để luôn phải đăng nhập lại khi debug
    // await userRepository.logout();
    // developer.log('Đã xóa token cũ (chỉ ở chế độ debug)');
    
    final isLogged = await userRepository.isLoggedIn();
    
    developer.log('Trạng thái đăng nhập: ${isLogged ? "Đã đăng nhập" : "Chưa đăng nhập"}');
    
    // Chỉ kiểm tra nếu có token
    if (isLogged) {
      try {
        // Kiểm tra token có hợp lệ không
        developer.log('Kiểm tra token và lấy thông tin người dùng');
        await userRepository.getUserProfile();
        
        // Thêm độ trễ nhỏ để hiển thị splash screen
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // Điều hướng đến màn hình chính nếu đã đăng nhập
        if (mounted && context.read<AuthBloc>().state is Authenticated) {
          developer.log('Token hợp lệ, chuyển hướng đến màn hình chính');
          Navigator.of(context).pushReplacementNamed(AppRoutes.main);
          return;
        }
      } catch (e) {
        developer.log('Token không hợp lệ hoặc lỗi: $e', error: e);
        // Đăng xuất nếu token không hợp lệ
        await userRepository.logout();
      }
    }
    
    // Thêm độ trễ nhỏ để hiển thị splash screen
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Nếu không có token hoặc token không hợp lệ, điều hướng đến màn hình đăng nhập
    if (mounted) {
      developer.log('Chuyển hướng đến màn hình đăng nhập');
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    
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

