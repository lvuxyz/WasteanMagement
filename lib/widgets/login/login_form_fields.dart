import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final usernameLabel = l10n != null ? l10n.username : 'Username';
    final usernameHint = l10n != null ? l10n.enterUsername : 'Enter your username';
    final usernameRequired = l10n != null ? l10n.usernameRequired : 'Username is required';
    final passwordLabel = l10n != null ? l10n.password : 'Password';
    final passwordHint = l10n != null ? l10n.enterPassword : 'Enter your password';
    final passwordRequired = l10n != null ? l10n.passwordRequired : 'Password is required';
    
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