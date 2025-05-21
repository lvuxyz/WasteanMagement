import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/user_repository.dart';
import 'dart:developer' as developer;

class AdminCubit extends Cubit<bool> {
  final UserRepository userRepository;
  
  AdminCubit({required this.userRepository}) : super(false);
  
  Future<void> checkAdminStatus() async {
    try {
      developer.log('Checking admin status...');
      final user = await userRepository.getUserProfile();
      
      // Detailed logging
      developer.log('User roles: ${user.roles ?? "null"}');
      developer.log('isAdmin check: roles contains ADMIN or admin? ${user.roles?.contains('ADMIN') ?? false} || ${user.roles?.contains('admin') ?? false}');
      developer.log('User isAdmin property: ${user.isAdmin}');
      
      emit(user.isAdmin);
      developer.log('User admin status emitted: ${user.isAdmin}');
    } catch (e) {
      developer.log('Error checking admin privileges: $e', error: e);
      emit(false);
    }
  }
} 