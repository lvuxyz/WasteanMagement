import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/profile/profile_menu_item.dart';
import '../blocs/simple_profile/simple_profile_bloc.dart';
import '../blocs/simple_profile/simple_profile_event.dart';
import '../blocs/simple_profile/simple_profile_state.dart';
import '../blocs/auth/auth_bloc.dart';

class SimpleProfileScreen extends StatelessWidget {
  const SimpleProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SimpleProfileBloc(
        authBloc: context.read<AuthBloc>(),
      )..add(LoadProfileMenuItems()),
      child: Scaffold(
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
        body: BlocListener<SimpleProfileBloc, SimpleProfileState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              // Navigate to login screen or handle logout success
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            } else if (state is LogoutFailure) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                BlocBuilder<SimpleProfileBloc, SimpleProfileState>(
                  builder: (context, state) {
                    if (state is SimpleProfileLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SimpleProfileLoaded) {
                      return _buildProfileMenuItems(context, state.menuItems);
                    } else if (state is SimpleProfileError) {
                      return Center(child: Text(state.error));
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenuItems(BuildContext context, List<Map<String, dynamic>> menuItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: menuItems.map((item) {
          return ProfileMenuItem(
            icon: item['icon'],
            title: item['title'],
            onTap: () {
              if (item['route'] == '/logout') {
                context.read<SimpleProfileBloc>().add(LogoutRequested());
              } else {
                // Navigate to the specified route
                Navigator.of(context).pushNamed(item['route']);
              }
            },
          );
        }).toList(),
      ),
    );
  }
} 

