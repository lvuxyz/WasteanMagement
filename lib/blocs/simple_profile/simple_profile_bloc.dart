import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart' as auth_events;
import 'simple_profile_event.dart';
import 'simple_profile_state.dart';

class SimpleProfileBloc extends Bloc<SimpleProfileEvent, SimpleProfileState> {
  final AuthBloc? authBloc;

  SimpleProfileBloc({this.authBloc}) : super(SimpleProfileInitial()) {
    on<LoadProfileMenuItems>(_onLoadProfileMenuItems);
    on<LogoutRequested>(_onLogoutRequested);
  }

  void _onLoadProfileMenuItems(
    LoadProfileMenuItems event,
    Emitter<SimpleProfileState> emit,
  ) {
    developer.log('Loading profile menu items');
    emit(SimpleProfileLoading());

    try {
      // Define menu items
      final List<Map<String, dynamic>> menuItems = [
        {
          'icon': Icons.person_outline,
          'title': 'Account',
          'route': '/account',
        },
        {
          'icon': Icons.repeat,
          'title': 'Recurring Details',
          'route': '/recurring',
        },
        {
          'icon': Icons.email_outlined,
          'title': 'Contact Us',
          'route': '/contact',
        },
        {
          'icon': Icons.description_outlined,
          'title': 'Terms & Conditions',
          'route': '/terms',
        },
        {
          'icon': Icons.privacy_tip_outlined,
          'title': 'Privacy Policy',
          'route': '/privacy',
        },
        {
          'icon': Icons.info_outline,
          'title': 'About',
          'route': '/about',
        },
        {
          'icon': Icons.location_on_outlined,
          'title': 'Location',
          'route': '/location',
        },
        {
          'icon': Icons.logout,
          'title': 'Logout',
          'route': '/logout',
        },
      ];

      emit(SimpleProfileLoaded(menuItems: menuItems));
    } catch (e) {
      developer.log('Error loading profile menu items: $e');
      emit(SimpleProfileError(error: 'Failed to load profile menu items'));
    }
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<SimpleProfileState> emit,
  ) async {
    developer.log('Logout requested');
    emit(LogoutInProgress());

    try {
      // Notify AuthBloc about logout
      if (authBloc != null) {
        authBloc!.add(auth_events.LogoutRequested());
        emit(LogoutSuccess());
      } else {
        throw Exception('AuthBloc is not available');
      }
    } catch (e) {
      developer.log('Error during logout: $e');
      emit(LogoutFailure(error: 'Failed to logout: $e'));
    }
  }
} 