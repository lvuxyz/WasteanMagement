import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'blocs/language/language_bloc.dart';
import 'blocs/language/language_event.dart';
import 'blocs/language/language_state.dart';
import 'blocs/language/language_repository.dart';
import 'screens/language_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    BlocProvider(
      create: (context) => LanguageBloc(
        repository: LanguageRepository(),
      )..add(const LoadLanguage()),
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
            locale: Locale(state.languageCode),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomePage(),
          );
        }
        
        // Màn hình loading khi đang tải ngôn ngữ
        return const MaterialApp(
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

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appTitle = l10n != null ? l10n.appTitle : 'Waste Management App';
    final languageScreenTitle = l10n != null ? l10n.languageScreenTitle : 'Select Language';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Mở màn hình chọn ngôn ngữ và đợi kết quả
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSelectionScreen(),
                  ),
                );
                
                // Nếu có kết quả trả về (mã ngôn ngữ), cập nhật ngôn ngữ cho toàn bộ ứng dụng
                if (result != null && context.mounted) {
                  // Cập nhật ngôn ngữ cho LanguageBloc toàn cục
                  context.read<LanguageBloc>().add(ChangeLanguage(result));
                  
                  // Hiển thị thông báo thành công
                  final successMessage = l10n != null ? l10n.languageChangeSuccess : 'Language changed successfully';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(successMessage),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(languageScreenTitle),
            ),
          ],
        ),
      ),
    );
  }
}