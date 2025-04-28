import 'package:flutter/material.dart';
import 'package:wasteanmagement/screens/waste_type/waste_type_management_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/main_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/map_screen.dart';
import 'screens/waste_classification_guide_screen.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String forgotPassword = '/forgot-password';
  static const String map = '/map';
  static const String wasteTypeManagement = '/waste-type';
  static const String wasteClassificationGuide = '/waste-guide';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case wasteTypeManagement:
        return MaterialPageRoute(builder: (_) => const WasteTypeManagementScreen());
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
    // Thêm case này
      case wasteClassificationGuide:
        return MaterialPageRoute(builder: (_) => const WasteClassificationGuideScreen());

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