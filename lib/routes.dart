import 'package:flutter/material.dart';
import 'package:wasteanmagement/screens/create_transaction_screen.dart';
import 'package:wasteanmagement/screens/transaction/transaction_add_screen.dart';
import 'package:wasteanmagement/screens/transaction/transaction_management_screen.dart';
import 'package:wasteanmagement/screens/transaction/transaction_details_screen.dart';
import 'package:wasteanmagement/screens/transaction/transaction_edit_screen.dart';
import 'package:wasteanmagement/screens/waste_type/waste_type_management_screen.dart';
import 'package:wasteanmagement/screens/reward/reward_screen.dart';
import 'package:wasteanmagement/screens/reward/reward_statistics_screen.dart';
import 'package:wasteanmagement/screens/reward/reward_rankings_screen.dart';
import 'package:wasteanmagement/screens/reward/admin_reward_management_screen.dart';
import 'package:wasteanmagement/screens/reward/add_reward_screen.dart';
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
import 'screens/collection_point/collection_point_create_screen.dart';
import 'screens/collection_point/collection_point_details_screen.dart';
import 'screens/collection_point/location_picker_screen.dart';
import 'screens/waste_type/waste_type_collection_points_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/view_profile_screen.dart';
import 'screens/about_app_screen.dart';
import 'screens/help_and_guidance_screen.dart';
import 'screens/change_password.dart';
import 'screens/edit_profile_screen.dart';

class AppRoutes {
  static const String welcome = '/';
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
  static const String collectionPointCreate = '/collection-points/create';
  static const String collectionPointDetails = '/collection-points/details';
  static const String transactions = '/transactions';
  static const String createTransaction = '/create-transaction';
  static const String addTransaction = '/add-transaction';
  static const String transactionDetails = '/transaction-details';
  static const String editTransaction = '/edit-transaction';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String viewProfile = '/view-profile';
  static const String editProfile = '/edit-profile';
  static const String about = '/about';
  static const String help = '/help';
  static const String changePassword = '/change-password';
  
  // Reward routes
  static const String rewards = '/rewards';
  static const String rewardStatistics = '/rewards/statistics';
  static const String rewardRankings = '/rewards/rankings';
  static const String adminRewardManagement = '/admin/rewards';
  static const String addReward = '/admin/rewards/add';
  static const String locationPicker = '/location-picker';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Reward routes
      case rewards:
        return MaterialPageRoute(builder: (_) => const RewardScreen(isInTabView: false));
      case rewardStatistics:
        return MaterialPageRoute(builder: (_) => const RewardStatisticsScreen());
      case rewardRankings:
        return MaterialPageRoute(builder: (_) => const RewardRankingsScreen());
      case adminRewardManagement:
        return MaterialPageRoute(builder: (_) => const AdminRewardManagementScreen());
      case addReward:
        return MaterialPageRoute(builder: (_) => const AddRewardScreen());
        
      case transactions:
        return MaterialPageRoute(builder: (_) => const TransactionManagementScreen());
      case createTransaction:
        return MaterialPageRoute(builder: (_) => const CreateTransactionScreen());
      case addTransaction:
        return MaterialPageRoute(
          builder: (context) {
            return const TransactionAddScreen();
          }
        );
      case transactionDetails:
        final transactionId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => TransactionDetailsScreen(transactionId: transactionId),
        );
      case editTransaction:
        final transactionId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => TransactionEditScreen(transactionId: transactionId),
        );
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
      case collectionPointCreate:
        return MaterialPageRoute(builder: (_) => const CollectionPointCreateScreen());
      case collectionPointDetails:
        final collectionPointId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => CollectionPointDetailsScreen(collectionPointId: collectionPointId),
        );
      case collectionPointWasteTypes:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CollectionPointWasteTypesScreen(
            collectionPointId: args['collectionPointId'],
            collectionPointName: args['collectionPointName'],
          ),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case viewProfile:
        return MaterialPageRoute(builder: (_) => const ViewProfileScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutAppScreen());
      case help:
        return MaterialPageRoute(builder: (_) => const HelpAndGuidanceScreen());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case locationPicker:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LocationPickerScreen(
            initialLatitude: args?['initialLatitude'] as double?,
            initialLongitude: args?['initialLongitude'] as double?,
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