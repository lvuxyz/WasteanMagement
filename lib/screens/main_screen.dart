import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/user_repository.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import 'profile_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 80, color: Color(0xFF8BC34A)),
                SizedBox(height: 20),
                Text(
                  'Địa Điểm',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8BC34A),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Tìm các điểm thu gom rác gần bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case 2:
        return Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.recycling, size: 80, color: Color(0xFF8BC34A)),
                SizedBox(height: 20),
                Text(
                  'Tái Chế',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8BC34A),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Quản lý hoạt động tái chế của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case 3:
        return Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 80, color: Color(0xFF8BC34A)),
                SizedBox(height: 20),
                Text(
                  'Thống Kê',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8BC34A),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Xem thống kê rác thải và tái chế của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case 4:
        // Sử dụng profile_screen với BLoC
        return BlocProvider(
          create: (context) => ProfileBloc(
            userRepository: RepositoryProvider.of<UserRepository>(context),
          )..add(ProfileFetchEvent()),
          child: const ProfileScreen(),
        );
      default:
        return const HomeScreen();
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF8BC34A),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Địa điểm',
            ),
            BottomNavigationBarItem(
              icon: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF8BC34A), width: 3),
                ),
                child: const Icon(Icons.recycling, color: Color(0xFF8BC34A)),
              ),
              label: 'Tái chế',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Thống kê',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }
} 