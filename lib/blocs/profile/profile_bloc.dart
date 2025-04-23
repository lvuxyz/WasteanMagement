import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/repositories/user_repository.dart';
import '../../core/error/exceptions.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc({required this.userRepository}) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(
      FetchProfile event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());
    try {
      final user = await userRepository.getUserProfile();
      emit(ProfileLoaded(user));
    } on UnauthorizedException catch (e) {
      emit(ProfileError(e.toString()));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfile event,
      Emitter<ProfileState> emit,
      ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileLoading());
      try {
        final user = await userRepository.updateUserProfile(
          fullName: event.fullName,
          email: event.email,
          phone: event.phone,
          address: event.address,
        );
        emit(ProfileUpdateSuccess(user));
        emit(ProfileLoaded(user));
      } on UnauthorizedException catch (e) {
        emit(ProfileError(e.toString()));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }
}