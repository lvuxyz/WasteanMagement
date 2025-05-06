import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../common/custom_text_field.dart';

class ForgotPasswordFormField extends StatelessWidget {
  final TextEditingController emailController;

  const ForgotPasswordFormField({
    super.key,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final emailLabel = l10n.email;
    final emailHint = l10n.enterEmail;
    final emailRequired = l10n.emailRequired;
    final invalidEmail = l10n.invalidEmail;

    return CustomTextField(
      labelText: emailLabel,
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

