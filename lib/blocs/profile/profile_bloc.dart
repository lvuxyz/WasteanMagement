import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc({required this.userRepository}) : super(ProfileInitial()) {
    on<ProfileFetchEvent>(_onProfileFetch);
    on<ProfileUpdateEvent>(_onProfileUpdate);
  }

  Future<void> _onProfileFetch(
    ProfileFetchEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await userRepository.getUserProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onProfileUpdate(
    ProfileUpdateEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileLoading());
      try {
        final updatedUser = await userRepository.updateUserProfile(
          fullName: event.fullName,
          email: event.email,
          phone: event.phone,
          address: event.address,
        );
        emit(ProfileLoaded(updatedUser));
        emit(ProfileUpdateSuccess());
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }
} 