import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/forgot_password/forgot_password_bloc.dart';
import '../blocs/language/language_bloc.dart';
import '../generated/l10n.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/forgot_password/forgot_password_form.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: CustomAppBar.localized(
              context: context,
              titleBuilder: (l10n) => l10n.forgotPasswordTitle,
              showLanguageSelector: true,
            ),
            body: BlocProvider.value(
              value: BlocProvider.of<LanguageBloc>(context),
              child: const SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ForgotPasswordForm(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 

