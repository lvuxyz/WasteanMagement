import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/login/login_bloc.dart';
import '../blocs/login/login_state.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/login/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(),
        body: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: AppColors.errorRed,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is LoginSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đăng nhập thành công! Xin chào ${state.username}'),
                  backgroundColor: AppColors.primaryGreen,
                  duration: const Duration(seconds: 3),
                ),
              );
              // Chuyển hướng tới màn hình chính nếu đăng nhập thành công
            }
          },
          child: const LoginForm(),
        ),
      ),
    );
  }
}
