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
      
      // Kiểm tra quyền admin từ cả hai nguồn
      final bool isAdminFromProperty = user.isAdmin;
      final bool hasAdminRole = (user.roles?.any((role) => 
          role.toLowerCase() == 'admin') ?? false);
          
      final bool finalIsAdmin = isAdminFromProperty || hasAdminRole;
          
      developer.log('Admin check: isAdminFromProperty=$isAdminFromProperty, hasAdminRole=$hasAdminRole');
      developer.log('Final admin status to emit: $finalIsAdmin');
      
      emit(finalIsAdmin);
      developer.log('User admin status emitted: $finalIsAdmin');
    } catch (e) {
      developer.log('Error checking admin privileges: $e', error: e);
      // Ghi log chi tiết hơn
      developer.log('Stack trace: ${StackTrace.current}');
      // Không thay đổi trạng thái hiện tại nếu có lỗi
      emit(false);
    }
  }
  
  // Phương thức nóng để cập nhật trạng thái admin
  void forceUpdateAdminStatus(bool isAdmin) {
    developer.log('Force updating admin status to: $isAdmin');
    emit(isAdmin);
  }
} 