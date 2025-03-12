import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/forgot_password/forgot_password_bloc.dart';
import '../../blocs/forgot_password/forgot_password_event.dart';
import '../../blocs/forgot_password/forgot_password_state.dart';
import '../../utils/app_colors.dart';
import 'forgot_password_form_field.dart';
import 'forgot_password_submit_button.dart';
import 'login_link.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Đừng lo lắng! Điều đó xảy ra. Vui lòng nhập email được liên kết với tài khoản của bạn.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              
              // Email field
              ForgotPasswordFormField(
                emailController: _emailController,
              ),
              
              const SizedBox(height: 30),
              
              // Submit button
              ForgotPasswordSubmitButton(
                formKey: _formKey,
                emailController: _emailController,
              ),
              
              const SizedBox(height: 20),
              
              // Login link
              const LoginLink(),
            ],
          ),
        ),
      ),
    );
  }
} 