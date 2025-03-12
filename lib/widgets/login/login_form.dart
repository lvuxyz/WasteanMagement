import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/login/login_bloc.dart';
import '../../blocs/login/login_event.dart';
import '../../blocs/login/login_state.dart';
import '../../utils/app_colors.dart';
import 'login_form_fields.dart';
import 'login_submit_button.dart';
import 'forgot_password_link.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              
              // Form fields
              LoginFormFields(
                usernameController: _usernameController,
                passwordController: _passwordController,
              ),
              
              const SizedBox(height: 10),
              
              // Forgot password link
              const ForgotPasswordLink(),
              
              const SizedBox(height: 30),
              
              // Login button
              LoginSubmitButton(
                formKey: _formKey,
                usernameController: _usernameController,
                passwordController: _passwordController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}