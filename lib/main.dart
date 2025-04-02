import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'blocs/language/language_bloc.dart';
import 'blocs/language/language_event.dart';
import 'blocs/language/language_state.dart';
import 'blocs/language/language_repository.dart';
import 'repositories/user_repository.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/simple_profile_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LanguageRepository>(
          create: (context) => LanguageRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(),
        ),
      ],
      child: BlocProvider(
        create: (context) => LanguageBloc(
          repository: context.read<LanguageRepository>(),
        )..add(const LoadLanguage()),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LanguageBloc, LanguageState>(
      listener: (context, state) {
        // Lắng nghe sự thay đổi ngôn ngữ để xử lý nếu cần
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
        if (state is LanguageLoaded) {
          return MaterialApp(
            title: 'Waste Management App',
            theme: ThemeData(
              primarySwatch: Colors.green,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: 'Poppins',
            ),
            debugShowCheckedModeBanner: false,
            locale: Locale(state.languageCode),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
            routes: {
              '/profile': (context) => const ProfileScreen(),
              '/simple_profile': (context) => const SimpleProfileScreen(),
            },
          );
        }
        
        // Màn hình loading khi đang tải ngôn ngữ
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}