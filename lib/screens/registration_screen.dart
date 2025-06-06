import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../generated/l10n.dart';
import '../blocs/registration/registration_bloc.dart';
import '../blocs/registration/registration_state.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/registration/registration_form.dart';
import 'dart:developer' as developer;

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final registrationSuccessText = l10n.registrationSuccess;

    return BlocProvider(
      create: (context) => RegistrationBloc(context: context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: 'Đăng ký'),
        body: BlocListener<RegistrationBloc, RegistrationState>(
          listener: (context, state) {
            if (state is RegistrationFailure) {
              developer.log('Registration failed: ${state.error}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: AppColors.errorRed,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is RegistrationSuccess) {
              developer.log('Registration successful');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(registrationSuccessText),
                  backgroundColor: AppColors.primaryGreen,
                  duration: const Duration(seconds: 3),
                ),
              );
              // Navigate to login screen after successful registration
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) Navigator.of(context).pop();
              });
            }
          },
          child: const RegistrationForm(),
        ),
      ),
    );
  }
}