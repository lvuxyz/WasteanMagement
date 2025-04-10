import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../blocs/forgot_password/forgot_password_bloc.dart';
import '../../blocs/forgot_password/forgot_password_event.dart';
import '../../blocs/forgot_password/forgot_password_state.dart';
import '../common/custom_button.dart';

class ForgotPasswordSubmitButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;

  const ForgotPasswordSubmitButton({
    super.key,
    required this.formKey,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resetPasswordText = l10n.resetPassword;

    return BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
      builder: (context, state) {
        return CustomButton(
          text: resetPasswordText,
          isLoading: state is ForgotPasswordLoading,
          onPressed: () {
            if (formKey.currentState!.validate()) {
              context.read<ForgotPasswordBloc>().add(
                    ForgotPasswordSubmitted(
                      email: emailController.text,
                    ),
                  );
            }
          },
        );
      },
    );
  }
} 