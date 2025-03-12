import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/forgot_password/forgot_password_bloc.dart';
import '../blocs/forgot_password/forgot_password_state.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/forgot_password/forgot_password_form.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(),
        body: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: AppColors.errorRed,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is ForgotPasswordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mã xác nhận đã được gửi đến ${state.email}'),
                  backgroundColor: AppColors.primaryGreen,
                  duration: const Duration(seconds: 3),
                ),
              );
              // Navigate to verification code screen
              // Navigator.pushReplacementNamed(context, '/verification');
            }
          },
          child: const ForgotPasswordForm(),
        ),
      ),
    );
  }
} 