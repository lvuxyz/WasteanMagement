import 'package:equatable/equatable.dart';

abstract class SimpleProfileEvent extends Equatable {
  const SimpleProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfileMenuItems extends SimpleProfileEvent {}

class LogoutRequested extends SimpleProfileEvent {} 