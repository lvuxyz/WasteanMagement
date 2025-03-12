import 'package:flutter/material.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username/Email field
        CustomTextField(
          label: 'Email hoặc tên đăng nhập',
          hintText: 'Nhập email hoặc tên đăng nhập',
          controller: widget.usernameController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email hoặc tên đăng nhập';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        // Password field
        CustomTextField(
          label: 'Mật khẩu',
          hintText: 'Nhập mật khẩu',
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
              return 'Vui lòng nhập mật khẩu';
            }
            return null;
          },
        ),
      ],
    );
  }
} 