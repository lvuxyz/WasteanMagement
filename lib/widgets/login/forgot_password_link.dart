import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../generated/l10n.dart';
import '../../blocs/language/language_bloc.dart';
import '../../screens/forgot_password_screen.dart';
import '../../utils/app_colors.dart';

class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final forgotPasswordText = l10n.forgotPassword;
    
    // Lấy LanguageBloc hiện tại để truyền sang màn hình mới
    final languageBloc = BlocProvider.of<LanguageBloc>(context);
    
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: languageBloc,
                child: const ForgotPasswordScreen(),
              ),
            ),
          );
        },
        child: Text(
          forgotPasswordText,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

