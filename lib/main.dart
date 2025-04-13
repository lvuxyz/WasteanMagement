import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wasteanmagement/blocs/auth/auth_bloc.dart';
import 'package:wasteanmagement/screens/login_screen.dart';
import 'blocs/language/language_bloc.dart';
import 'blocs/language/language_event.dart';
import 'blocs/language/language_state.dart';
import 'blocs/language/language_repository.dart';
import 'repositories/user_repository.dart';
import 'screens/profile_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LanguageBloc(
            repository: LanguageRepository(),
          )..add(const LoadLanguage()),
        ),
        // Thêm các BlocProvider khác nếu cần
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LanguageBloc, LanguageState>(
      listener: (context, state) {
        if (state is LanguageError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        // Mặc định sử dụng tiếng Anh nếu chưa tải được ngôn ngữ
        String languageCode = 'en';

        if (state is LanguageLoaded) {
          languageCode = state.languageCode;
        }

        return MaterialApp(
          title: 'Waste Management App',
          theme: ThemeData(
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Poppins',
          ),
          debugShowCheckedModeBanner: false,
          locale: Locale(languageCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        );
      },
    );
  }
}