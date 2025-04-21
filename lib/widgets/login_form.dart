import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/form/auth_form_bloc.dart';
import '../blocs/form/auth_form_event.dart';
import '../blocs/form/auth_form_state.dart';
import '../repositories/auth_repository.dart';
import '../utils/app_colors.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthFormBloc(authRepository: context.read<AuthRepository>()),
      child: BlocConsumer<AuthFormBloc, AuthFormState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.errorRed,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return Form(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tên đăng nhập', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildEmailField(context, state),
                  const SizedBox(height: 20),
                  const Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildPasswordField(context, state),
                  const SizedBox(height: 16),
                  _buildRememberMeAndForgotPassword(context),
                  const SizedBox(height: 30),
                  _buildLoginButton(context, state),
                  if (state.isSubmitting)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmailField(BuildContext context, AuthFormState state) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: "Tên đăng nhập",
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        errorText: !state.isEmailValid && state.email.isNotEmpty ? 'Email không hợp lệ' : null,
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) => context.read<AuthFormBloc>().add(EmailChanged(value)),
    );
  }

  Widget _buildPasswordField(BuildContext context, AuthFormState state) {
    return TextFormField(
      obscureText: !state.isPasswordVisible,
      decoration: InputDecoration(
        hintText: "Mật khẩu",
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        suffixIcon: IconButton(
          icon: Icon(state.isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
          onPressed: () => context.read<AuthFormBloc>().add(const TogglePasswordVisibility()),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        errorText: !state.isPasswordValid && state.password.isNotEmpty
            ? 'Mật khẩu phải có ít nhất 6 ký tự, 1 chữ hoa, 1 số'
            : null,
      ),
      onChanged: (value) => context.read<AuthFormBloc>().add(PasswordChanged(value)),
    );
  }

  Widget _buildRememberMeAndForgotPassword(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: context.read<AuthFormBloc>().state.rememberMe,
              onChanged: (value) {
                context.read<AuthFormBloc>().add(RememberMeChanged(value ?? false));
              },
              activeColor: Colors.green,
            ),
            const Text('Nhớ mình nha'),
          ],
        ),
        TextButton(
          onPressed: () {
            // TODO: Thêm chức năng quên mật khẩu
          },
          child: const Text(
            'Quên mật khẩu?',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, AuthFormState state) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: state.isFormValid && !state.isSubmitting
            ? () => context.read<AuthFormBloc>().add(const FormSubmitted())
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: state.isFormValid ? Colors.lightGreen : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: state.isSubmitting
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Text('Đăng nhập', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

