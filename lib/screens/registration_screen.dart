import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/registration/registration_bloc.dart';
import '../blocs/registration/registration_state.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/registration/registration_form.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegistrationBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(),
        body: BlocListener<RegistrationBloc, RegistrationState>(
          listener: (context, state) {
            if (state is RegistrationFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: AppColors.errorRed,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is RegistrationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đăng ký thành công! Xin chào ${state.username}'),
                  backgroundColor: AppColors.primaryGreen,
                  duration: const Duration(seconds: 3),
                ),
              );
              // Navigate to main screen after successful registration
              // Navigator.pushReplacementNamed(context, '/home');
            }
          },
          child: const RegistrationForm(),
        ),
      ),
    );
  }
} 