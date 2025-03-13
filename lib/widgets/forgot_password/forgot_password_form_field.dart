import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../common/custom_text_field.dart';

class ForgotPasswordFormField extends StatelessWidget {
  final TextEditingController emailController;

  const ForgotPasswordFormField({
    super.key,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final emailLabel = l10n.email;
    final emailHint = l10n.enterEmail;
    final emailRequired = l10n.emailRequired;
    final invalidEmail = l10n.invalidEmail;

    return CustomTextField(
      label: emailLabel,
      hintText: emailHint,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return emailRequired;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return invalidEmail;
        }
        return null;
      },
    );
  }
} 