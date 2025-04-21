import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../screens/login_screen.dart';
import '../../utils/app_colors.dart';

class LoginLink extends StatelessWidget {
  const LoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final alreadyHaveAccountText = l10n.alreadyHaveAccount;
    
    return Center(
      child: TextButton(
        onPressed: () {
          // Đóng màn hình hiện tại và trở về màn hình đăng nhập
          Navigator.pop(context);
        },
        child: Text(
          alreadyHaveAccountText,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
} 

