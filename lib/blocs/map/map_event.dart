import 'package:equatable/equatable.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapInitialized extends MapEvent {
  final MapboxMapController controller;

  const MapInitialized(this.controller);

  @override
  List<Object?> get props => [controller];
}

class LoadUserLocation extends MapEvent {}

class LoadCollectionPoints extends MapEvent {}

class SelectCollectionPoint extends MapEvent {
  final int pointId;

  const SelectCollectionPoint(this.pointId);

  @override
  List<Object?> get props => [pointId];
}