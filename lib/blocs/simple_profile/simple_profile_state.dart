import 'package:equatable/equatable.dart';

abstract class SimpleProfileState extends Equatable {
  const SimpleProfileState();

  @override
  List<Object> get props => [];
}

class SimpleProfileInitial extends SimpleProfileState {}

class SimpleProfileLoading extends SimpleProfileState {}

class SimpleProfileLoaded extends SimpleProfileState {
  final List<Map<String, dynamic>> menuItems;

  const SimpleProfileLoaded({required this.menuItems});

  @override
  List<Object> get props => [menuItems];
}

class SimpleProfileError extends SimpleProfileState {
  final String error;

  const SimpleProfileError({required this.error});

  @override
  List<Object> get props => [error];
}

class LogoutInProgress extends SimpleProfileState {}

class LogoutSuccess extends SimpleProfileState {}

class LogoutFailure extends SimpleProfileState {
  final String error;

  const LogoutFailure({required this.error});

  @override
  List<Object> get props => [error];
} 