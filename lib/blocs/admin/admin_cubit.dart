import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/user_repository.dart';
import 'dart:developer' as developer;

class AdminCubit extends Cubit<bool> {
  final UserRepository userRepository;
  
  AdminCubit({required this.userRepository}) : super(false);
  
  Future<void> checkAdminStatus() async {
    try {
      final user = await userRepository.getUserProfile();
      emit(user.isAdmin);
      developer.log('User admin status: ${user.isAdmin}');
    } catch (e) {
      developer.log('Error checking admin privileges: $e', error: e);
      emit(false);
    }
  }
} 