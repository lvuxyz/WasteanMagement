import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../blocs/registration/registration_bloc.dart';
import '../../blocs/registration/registration_event.dart';
import '../../blocs/registration/registration_state.dart';
import '../../utils/app_colors.dart';

class RegistrationSubmitButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const RegistrationSubmitButton({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final registerText = l10n.register;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: BlocBuilder<RegistrationBloc, RegistrationState>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state is RegistrationLoading
                ? null
                : () {
                    if (formKey.currentState!.validate()) {
                      context.read<RegistrationBloc>().add(
                            RegistrationSubmitted(
                              email: emailController.text,
                              password: passwordController.text,
                              confirmPassword: confirmPasswordController.text,
                            ),
                          );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.6),
            ),
            child: state is RegistrationLoading
                ? const CircularProgressIndicator(color: AppColors.white)
                : Text(
                    registerText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          );
        },
      ),
    );
  }
} 