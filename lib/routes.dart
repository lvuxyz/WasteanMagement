import 'package:flutter/material.dart';
import 'package:wasteanmagement/screens/transactions_screen.dart';
import 'package:wasteanmagement/screens/waste_type/waste_type_management_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/main_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/map_screen.dart';
import 'screens/waste_classification_guide_screen.dart';
import 'screens/recycling_progress_screen.dart';
import 'screens/waste_type/waste_type_add_screen.dart';
import 'screens/collection_point/collection_points_list_screen.dart';
import 'screens/collection_point/collection_point_waste_types_screen.dart';
import 'screens/waste_type/waste_type_collection_points_screen.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String forgotPassword = '/forgot-password';
  static const String map = '/map';
  static const String wasteTypeManagement = '/waste-type';
  static const String wasteTypeAdd = '/waste-type/add';
  static const String wasteTypeTest = '/waste-type-test';
  static const String wasteTypeCollectionPoints = '/waste-type/collection-points';
  static const String wasteClassificationGuide = '/waste-guide';
  static const String recyclingProgress = '/recycling-progress';
  static const String collectionPointsList = '/collection-points';
  static const String collectionPointWasteTypes = '/collection-point/waste-types';
  static const String transactions = '/transactions';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case transactions:
        return MaterialPageRoute(builder: (_) => const TransactionsScreen());
      case wasteTypeManagement:
        return MaterialPageRoute(builder: (_) => const WasteTypeManagementScreen());
      case wasteTypeAdd:
        return MaterialPageRoute(builder: (_) => const WasteTypeAddScreen());
      case wasteTypeCollectionPoints:
        final args = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => WasteTypeCollectionPointsScreen(wasteTypeId: args),
        );
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case map:
        return MaterialPageRoute(builder: (_) => const MapScreen());
      case wasteClassificationGuide:
        return MaterialPageRoute(builder: (_) => const WasteClassificationGuideScreen());
      case recyclingProgress:
        return MaterialPageRoute(builder: (_) => const RecyclingProgressScreen());
      case collectionPointsList:
        return MaterialPageRoute(builder: (_) => const CollectionPointsListScreen());
      case collectionPointWasteTypes:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CollectionPointWasteTypesScreen(
            collectionPointId: args['collectionPointId'],
            collectionPointName: args['collectionPointName'],
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route không tồn tại: ${settings.name}'),
            ),
          ),
        );
    }
  }
}