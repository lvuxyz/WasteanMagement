import 'package:flutter/material.dart';
import '../widgets/common/custom_bottom_navigation.dart';
import 'profile_screen.dart';
import 'home_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Simplified screens for easier integration
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // Initialize screens list
    _screens = [
      // Dashboard screen
      const HomeScreen(),
      // Waste Management screen placeholder
      Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            'Màn hình Quản lý - Đang phát triển',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
      // Map screen placeholder
      Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            'Màn hình Bản đồ - Đang phát triển',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
      // Profile screen
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}