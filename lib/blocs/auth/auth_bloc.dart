import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/repositories/user_repository.dart';
import '../../core/error/exceptions.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin/admin_cubit.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;
  final AdminCubit? adminCubit;

  AuthBloc({
    required this.userRepository, 
    this.adminCubit,
  }) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthenticationStatus>(_onCheckAuthenticationStatus);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final user = await userRepository.login(
        event.username,
        event.password,
      );
      emit(Authenticated(user));
    } on UnauthorizedException catch (e) {
      emit(AuthError(e.toString()));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    // Implement registration logic
    emit(AuthLoading());
    // Add logic here based on your user repository methods
  }

  Future<void> _onForgotPasswordSubmitted(
      ForgotPasswordSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      await userRepository.forgotPassword(event.email);
      emit(ForgotPasswordSent(event.email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Trong AuthBloc class, phương thức _onLogoutRequested
  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      // Clear all chat history for security
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = <String>[];
      
      // Find and clear all chat history keys
      prefs.getKeys().forEach((key) {
        if (key.startsWith('chat_history_user_')) {
          keysToRemove.add(key);
        }
      });
      
      // Remove found keys
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      
      // Clear admin status if AdminCubit is available
      if (adminCubit != null) {
        adminCubit!.clearAdminStatus();
      }
      
      // Perform regular logout
      await userRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthenticationStatus(
      CheckAuthenticationStatus event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await userRepository.isLoggedIn();
      if (isLoggedIn) {
        try {
          final user = await userRepository.getUserProfile();
          emit(Authenticated(user));
        } catch (e) {
          // Nếu lỗi khi lấy thông tin người dùng, vẫn coi là đã đăng xuất
          if (e is UnauthorizedException) {
            emit(Unauthenticated());
          } else {
            // Thử lấy user từ cache
            try {
              final cachedUser = await userRepository.localDataSource.getCachedUserProfile();
              if (cachedUser != null) {
                emit(Authenticated(cachedUser));
                return;
              }
            } catch (_) {}
            emit(Unauthenticated());
          }
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

}