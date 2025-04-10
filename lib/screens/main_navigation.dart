import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'profile_screen.dart';

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
      // Dashboard screen placeholder (replace with actual Dashboard when available)
      Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            'Màn hình Trang chủ',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delete_outline),
              activeIcon: Icon(Icons.delete),
              label: 'Quản lý',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Bản đồ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}