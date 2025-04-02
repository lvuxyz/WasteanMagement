import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';
import '../widgets/profile_menu_item.dart';
import '../repositories/user_repository.dart';
import 'account_details_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'User Profile',
          style: TextStyle(
            color: Color(0xFF8BC34A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ProfileLoaded) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileMenuItems(context),
                ],
              ),
            );
          }
          return const Center(child: Text('Something went wrong'));
        },
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: BlocProvider.of<ProfileBloc>(context),
                    child: const AccountDetailsScreen(),
                  ),
                ),
              );
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