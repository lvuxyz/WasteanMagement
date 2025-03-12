import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../common/custom_text_field.dart';

class ForgotPasswordFormField extends StatelessWidget {
  final TextEditingController emailController;

  const ForgotPasswordFormField({
    super.key,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: 'Địa chỉ email',
      hintText: 'Nhập địa chỉ email của bạn',
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Email không hợp lệ';
        }
        return null;
      },
    );
  }
} 