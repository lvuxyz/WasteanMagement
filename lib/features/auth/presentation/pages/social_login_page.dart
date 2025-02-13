import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_state.dart';
import '../../../../core/theme/app_colors.dart';

class SocialLoginPage extends StatelessWidget {
  const SocialLoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocProvider(
        create: (context) => AuthBloc(),
        child: const SafeArea(
          child: SingleChildScrollView(
            child: SocialLoginForm(),
          ),
        ),
      ),
    );
  }
}
