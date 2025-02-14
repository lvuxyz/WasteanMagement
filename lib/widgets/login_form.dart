import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/form/auth_form_bloc.dart';
import '../blocs/form/auth_form_event.dart';
import '../blocs/form/auth_form_state.dart';
import '../repositories/auth_repository.dart';
import '../utils/app_colors.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthFormBloc(authRepository: context.read<AuthRepository>()),
      child: BlocConsumer<AuthFormBloc, AuthFormState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.errorRed),
            );
          }
        },
        builder: (context, state) {
          return Form(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildEmailField(context, state),
                  const SizedBox(height: 20),
                  _buildPasswordField(context, state),
                  const SizedBox(height: 30),
                  _buildLoginButton(context, state),
                  if (state.isSubmitting)
                    const Padding(padding: EdgeInsets.only(top: 10), child: Center(child: CircularProgressIndicator())),
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
        labelText: 'Email',
        errorText: !state.isEmailValid && state.email.isNotEmpty ? 'Email không hợp lệ' : null,
        prefixIcon: const Icon(Icons.email),
      ),
      onChanged: (value) => context.read<AuthFormBloc>().add(EmailChanged(value)),
    );
  }

  Widget _buildPasswordField(BuildContext context, AuthFormState state) {
    return TextFormField(
      obscureText: !state.isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Mật khẩu',
        errorText: !state.isPasswordValid && state.password.isNotEmpty ? 'Mật khẩu yếu' : null,
        prefixIcon: const Icon(Icons.lock),
      ),
      onChanged: (value) => context.read<AuthFormBloc>().add(PasswordChanged(value)),
    );
  }

  Widget _buildLoginButton(BuildContext context, AuthFormState state) {
    return ElevatedButton(
      onPressed: state.isFormValid && !state.isSubmitting
          ? () => context.read<AuthFormBloc>().add(FormSubmitted())
          : null,
      child: Text(state.isSubmitting ? 'Đang đăng nhập...' : 'Đăng nhập'),
    );
  }
}
