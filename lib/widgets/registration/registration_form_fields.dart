import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../utils/app_colors.dart';
import '../common/custom_text_field.dart';

class RegistrationFormFields extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const RegistrationFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<RegistrationFormFields> createState() => _RegistrationFormFieldsState();
}

class _RegistrationFormFieldsState extends State<RegistrationFormFields> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final emailLabel = l10n.email;
    final emailHint = l10n.enterEmail;
    final emailRequired = l10n.emailRequired;
    final invalidEmail = l10n.invalidEmail;
    final passwordLabel = l10n.password;
    final passwordHint = l10n.enterPassword;
    final passwordRequired = l10n.passwordRequired;
    final confirmPasswordLabel = l10n.confirmPassword;
    final confirmPasswordHint = l10n.enterConfirmPassword;
    final confirmPasswordRequired = l10n.confirmPasswordRequired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        CustomTextField(
          label: emailLabel,
          hintText: emailHint,
          controller: widget.emailController,
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
        ),
        const SizedBox(height: 20),
        
        // Password field
        CustomTextField(
          label: passwordLabel,
          hintText: passwordHint,
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textGrey,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return passwordRequired;
            }
            if (value.length < 6) {
              return passwordRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        // Confirm Password field
        CustomTextField(
          label: confirmPasswordLabel,
          hintText: confirmPasswordHint,
          controller: widget.confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textGrey,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return confirmPasswordRequired;
            }
            if (value != widget.passwordController.text) {
              return confirmPasswordRequired;
            }
            return null;
          },
        ),
      ],
    );
  }
} 

