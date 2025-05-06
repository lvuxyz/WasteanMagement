import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:wasteanmagement/blocs/language/language_state.dart';
import 'package:wasteanmagement/core/api/api_client.dart';
import 'package:wasteanmagement/data/datasources/remote_data_source.dart';
import 'package:wasteanmagement/repositories/transaction_repository.dart';
import 'package:wasteanmagement/repositories/user_repository.dart';
import 'package:wasteanmagement/repositories/waste_type_repository.dart';
import 'package:wasteanmagement/repositories/collection_point_repository.dart';
import 'package:wasteanmagement/utils/secure_storage.dart';
import 'package:wasteanmagement/blocs/waste_type/waste_type_bloc.dart';
import 'package:provider/provider.dart';
import 'data/datasources/local_data_source.dart';
import 'data/repositories/language_repository.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/language/language_bloc.dart';
import 'blocs/language/language_event.dart';
import 'core/network/network_info.dart';
import 'routes.dart';
import 'generated/l10n.dart';
import 'utils/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

Future<void> main() async {

  await dotenv.dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();


  // Tạo các repository
  final localDataSource = LocalDataSource();
  final secureStorage = SecureStorage();
  final languageRepository = LanguageRepository(localDataSource: localDataSource);
  
  // Tạo ApiClient cho nhiều repository dùng chung
  final apiClient = ApiClient(
    client: http.Client(),
    secureStorage: secureStorage,
  );
  
  final userRepository = UserRepository(
    remoteDataSource: RemoteDataSource(apiClient: apiClient),
    localDataSource: localDataSource,
    networkInfo: NetworkInfoImpl(),
  );
  
  final wasteTypeRepository = WasteTypeRepository(apiClient: apiClient);
  final collectionPointRepository = CollectionPointRepository(apiClient: apiClient);
  final transactionRepository = TransactionRepository(apiClient: apiClient);

  runApp(
    MultiProvider(
      providers: [
        // Cung cấp ApiClient để các màn hình có thể truy cập
        Provider<ApiClient>.value(value: apiClient),
        // Repository providers
        RepositoryProvider<UserRepository>.value(value: userRepository),
        RepositoryProvider<LanguageRepository>.value(value: languageRepository),
        RepositoryProvider<WasteTypeRepository>.value(value: wasteTypeRepository),
        RepositoryProvider<CollectionPointRepository>.value(value: collectionPointRepository),
        RepositoryProvider<TransactionRepository>.value(value: transactionRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LanguageBloc(
              repository: languageRepository, // Sử dụng đối tượng đã khởi tạo trước đó
            )..add(const LoadLanguage()),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              userRepository: userRepository,
            )..add(CheckAuthenticationStatus()),
          ),
          BlocProvider(
            create: (context) => WasteTypeBloc(
              repository: wasteTypeRepository,
            ),
          ),
        ],
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
        // Mặc định là tiếng Anh nếu chưa tải ngôn ngữ
        String languageCode = 'en';

        if (state is LanguageLoaded) {
          languageCode = state.languageCode;
        }

        return MaterialApp(
          title: 'LVuRác - Ứng dụng Quản lý Chất thải',
          theme: ThemeData(
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Poppins',
            primaryColor: AppColors.primaryGreen,
            scaffoldBackgroundColor: AppColors.scaffoldBackground,
          ),
          debugShowCheckedModeBanner: false,
          locale: Locale(languageCode),
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          initialRoute: AppRoutes.welcome,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}