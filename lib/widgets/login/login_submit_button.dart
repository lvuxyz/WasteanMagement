import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../generated/l10n.dart';
import '../../blocs/login/login_bloc.dart';
import '../../blocs/login/login_event.dart';
import '../../blocs/login/login_state.dart';
import '../common/custom_button.dart';

class LoginSubmitButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const LoginSubmitButton({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final loginButtonText = l10n.login;
    
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return CustomButton(
          text: loginButtonText,
          isLoading: state is LoginLoading,
          onPressed: () {
            if (formKey.currentState!.validate()) {
              context.read<LoginBloc>().add(
                    LoginSubmitted(
                      username: usernameController.text,
                      password: passwordController.text,
                    ),
                  );
            }
          },
        );
      },
    );
  }
}

