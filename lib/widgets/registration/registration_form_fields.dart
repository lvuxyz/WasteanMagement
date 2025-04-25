import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../utils/app_colors.dart';
import '../common/custom_text_field.dart';

class RegistrationFormFields extends StatefulWidget {
  final TextEditingController fullNameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  const RegistrationFormFields({
    super.key,
    required this.fullNameController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.phoneController,
    required this.addressController,
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
    final fullNameLabel = l10n.fullName;
    final fullNameHint = l10n.enterFullName;
    final fullNameRequired = l10n.fullNameRequired;
    
    final usernameLabel = l10n.username;
    final usernameHint = l10n.enterUsername;
    final usernameRequired = l10n.usernameRequired;
    
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
    final passwordsDoNotMatch = l10n.passwordsDoNotMatch;
    
    final phoneLabel = "Phone";
    final phoneHint = "Enter your phone number";
    
    final addressLabel = "Address";
    final addressHint = "Enter your address";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Name field
        CustomTextField(
          label: fullNameLabel,
          hintText: fullNameHint,
          controller: widget.fullNameController,
          keyboardType: TextInputType.name,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return fullNameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        // Username field
        CustomTextField(
          label: usernameLabel,
          hintText: usernameHint,
          controller: widget.usernameController,
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return usernameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
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
        
        // Phone field
        CustomTextField(
          label: phoneLabel,
          hintText: phoneHint,
          controller: widget.phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        
        // Address field
        CustomTextField(
          label: addressLabel,
          hintText: addressHint,
          controller: widget.addressController,
          keyboardType: TextInputType.streetAddress,
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
              return "Password must be at least 6 characters";
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
              return passwordsDoNotMatch;
            }
            return null;
          },
        ),
      ],
    );
  }
} 

