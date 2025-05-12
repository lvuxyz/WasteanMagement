import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/repositories/user_repository.dart';
import 'dart:developer' as developer;
import '../screens/main_screen.dart';
import '../blocs/login/login_bloc.dart';
import '../blocs/login/login_state.dart';
import '../widgets/login/login_form.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_event.dart';
import '../blocs/language/language_state.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../generated/l10n.dart';
import 'registration_screen.dart';
import '../utils/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy localization
    final l10n = S.of(context);

    // Lấy các chuỗi từ localization
    final loginTitle = l10n.loginTitle;
    final dontHaveAccount = l10n.dontHaveAccount;
    final signUp = l10n.signUp;

    // Lấy AuthBloc từ context
    final authBloc = context.read<AuthBloc>();
    final userRepository = context.read<UserRepository>();
    final languageBloc = context.read<LanguageBloc>();

    developer.log('Khởi tạo LoginScreen');

    return BlocProvider(
      create: (context) => LoginBloc(
        userRepository: userRepository,
        authBloc: authBloc, // Truyền AuthBloc vào LoginBloc
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(loginTitle),
          actions: [
            // Language selector in app bar
            _buildLanguageSelector(context),
          ],
        ),
        body: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              final successMessage = l10n.loginSuccess(state.username);
              developer.log('Hiển thị thông báo đăng nhập thành công: $successMessage');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(successMessage),
                  backgroundColor: AppColors.primaryGreen,
                  duration: const Duration(seconds: 3),
                ),
              );

              // Điều hướng sau khi đăng nhập thành công
              developer.log('Chuyển hướng đến MainScreen với username: ${state.username}');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      // Cung cấp Repository
                      RepositoryProvider.value(
                        value: userRepository,
                      ),
                      // Truyền AuthBloc hiện tại
                      BlocProvider.value(
                        value: authBloc,
                      ),
                      // Truyền LanguageBloc hiện tại
                      BlocProvider.value(
                        value: languageBloc,
                      ),
                      // Chỉ cung cấp thay vì gọi FetchProfile ở đây
                      BlocProvider(
                        create: (context) => ProfileBloc(),
                      ),
                    ],
                    child: MainScreen(username: state.username),
                  ),
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
                        developer.log('Chuyển hướng đến màn hình đăng ký');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                RepositoryProvider.value(
                                  value: userRepository,
                                ),
                                BlocProvider.value(
                                  value: authBloc,
                                ),
                                BlocProvider.value(
                                  value: languageBloc,
                                ),
                              ],
                              child: const RegistrationScreen(),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        signUp,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
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
          developer.log('Thay đổi ngôn ngữ thành: $languageCode');
          context.read<LanguageBloc>().add(ChangeLanguage(languageCode));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Image.asset(
          flagAsset,
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            developer.log('Lỗi khi tải hình ảnh quốc kỳ: $flagAsset', error: error);
            return Icon(
              Icons.language,
              color: isSelected ? AppColors.primaryGreen : Colors.grey,
              size: 24,
            );
          },
        ),
      ),
    );
  }
}