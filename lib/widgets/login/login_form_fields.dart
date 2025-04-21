import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../utils/app_colors.dart';
import '../common/custom_text_field.dart';

class LoginFormFields extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const LoginFormFields({
    super.key,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  State<LoginFormFields> createState() => _LoginFormFieldsState();
}

class _LoginFormFieldsState extends State<LoginFormFields> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final usernameLabel = l10n.username;
    final usernameHint = l10n.enterUsername;
    final usernameRequired = l10n.usernameRequired;
    final passwordLabel = l10n.password;
    final passwordHint = l10n.enterPassword;
    final passwordRequired = l10n.passwordRequired;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username/Email field
        CustomTextField(
          label: usernameLabel,
          hintText: usernameHint,
          controller: widget.usernameController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return usernameRequired;
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
            return null;
          },
        ),
      ],
    );
  }
} 

