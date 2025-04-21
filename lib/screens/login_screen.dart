import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../blocs/login/login_bloc.dart';
import '../blocs/login/login_state.dart';
<<<<<<< HEAD
=======
import '../utils/app_colors.dart';
>>>>>>> bugfix/languageSelection
import '../widgets/login/login_form.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_event.dart';
import '../blocs/language/language_state.dart';
import 'registration_screen.dart';
import 'main_navigation.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final l10n = AppLocalizations.of(context);
=======
    // Kiểm tra xem AppLocalizations đã sẵn sàng chưa
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    // Nếu chưa sẵn sàng, sử dụng các giá trị mặc định
    final loginTitle = l10n?.loginTitle ?? 'Đăng nhập';
    final dontHaveAccount = l10n?.dontHaveAccount ?? 'Bạn chưa có tài khoản?';
    final signUp = l10n?.signUp ?? 'Đăng ký';
>>>>>>> bugfix/languageSelection

    return BlocProvider(
      create: (context) => LoginBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(loginTitle),
          actions: [
            // Language selector in app bar
            _buildLanguageSelector(context),
          ],
        ),
        body: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is LoginSuccess) {
<<<<<<< HEAD
              final successMessage = l10n.loginSuccess(state.username);
=======
              final successMessage = l10n?.loginSuccess(state.username) ??
                  'Đăng nhập thành công! Xin chào, ${state.username}';
>>>>>>> bugfix/languageSelection

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(successMessage),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
<<<<<<< HEAD
              // Chuyển đến MainNavigation thay vì DashboardScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigation(),
=======
              // Navigate to dashboard screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
>>>>>>> bugfix/languageSelection
                ),
              );
            }
          },
          child: Column(
            children: [
              const Expanded(
                child: LoginForm(),
              ),
              // Phần đăng ký ở cuối màn hình
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dontHaveAccount),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      },
                      child: Text(
                        signUp,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        if (state is LanguageLoaded) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // English language option
              _buildLanguageOption(
                context: context,
                languageCode: 'en',
                flagAsset: 'assets/flags/gb.png',
                isSelected: state.languageCode == 'en',
              ),

              const SizedBox(width: 8),

              // Vietnamese language option
              _buildLanguageOption(
                context: context,
                languageCode: 'vi',
                flagAsset: 'assets/flags/vn.png',
                isSelected: state.languageCode == 'vi',
              ),

              const SizedBox(width: 8),
            ],
          );
        }
        // Hiển thị một widget rỗng khi LanguageBloc chưa sẵn sàng
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageCode,
    required String flagAsset,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          context.read<LanguageBloc>().add(ChangeLanguage(languageCode));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Image.asset(
          flagAsset,
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}