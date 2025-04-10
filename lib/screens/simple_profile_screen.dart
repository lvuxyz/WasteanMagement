import 'package:flutter/material.dart';
import '../widgets/profile_menu_item.dart';

class SimpleProfileScreen extends StatelessWidget {
  const SimpleProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Hồ sơ người dùng',
          style: TextStyle(
            color: Color(0xFF8BC34A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Account',
            onTap: () {
              // Navigate to account details screen
            },
          ),
          ProfileMenuItem(
            icon: Icons.repeat,
            title: 'Recurring Details',
            onTap: () {
              // Navigate to recurring details screen
            },
          ),
          ProfileMenuItem(
            icon: Icons.email_outlined,
            title: 'Contact Us',
            onTap: () {
              // Navigate to contact us screen
            },
          ),
          ProfileMenuItem(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () {
              // Navigate to terms screen
            },
          ),
          ProfileMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // Navigate to privacy policy screen
            },
          ),
          ProfileMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              // Navigate to about screen
            },
          ),
          ProfileMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Location',
            onTap: () {
              // Navigate to location screen
            },
          ),
          ProfileMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
} 