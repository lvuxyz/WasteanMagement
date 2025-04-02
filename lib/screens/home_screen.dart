import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Placeholder pages for different tabs
  final List<Widget> _pages = [
    const Center(child: Text('Home Page')),
    const Center(child: Text('Location Page')),
    const Center(child: Text('Placeholder')), // This is for the center button
    const Center(child: Text('Refresh Page')),
    const Center(child: Text('Menu Page')),
  ];

  void _onItemTapped(int index) {
    // Skip the center button index (2) for normal navigation
    if (index != 2) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onCenterButtonPressed() {
    // Handle center button press - special action
    print('Center button pressed');
    // Add your logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildCustomNavigationBar(),
    );
  }

  Widget _buildCustomNavigationBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Regular navigation items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_outlined, 0),
              _buildNavItem(Icons.location_on_outlined, 1),
              // Empty space for the center button
              const SizedBox(width: 65),
              _buildNavItem(Icons.refresh_outlined, 3),
              _buildNavItem(Icons.apps_outlined, 4),
            ],
          ),
          // Center button
          Positioned(
            top: -15,
            child: _buildCenterButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    
    return IconButton(
      onPressed: () => _onItemTapped(index),
      icon: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      padding: const EdgeInsets.all(8),
      highlightColor: Colors.white24,
      splashColor: Colors.white24,
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: _onCenterButtonPressed,
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.currency_exchange,
          color: AppColors.primaryGreen,
          size: 30,
        ),
      ),
    );
  }
} 