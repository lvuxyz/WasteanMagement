import 'package:equatable/equatable.dart';
import 'package:location/location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapState extends Equatable {
  final bool isLoading;
  final MapboxMap? controller;
  final LocationData? userLocation;
  final List<Map<String, dynamic>> collectionPoints;
  final int? selectedPointId;
  final String? errorMessage;

  const MapState({
    this.isLoading = false,
    this.controller,
    this.userLocation,
    this.collectionPoints = const [],
    this.selectedPointId,
    this.errorMessage,
  });

  MapState copyWith({
    bool? isLoading,
    MapboxMap? controller,
    LocationData? userLocation,
    List<Map<String, dynamic>>? collectionPoints,
    int? selectedPointId,
    String? errorMessage,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      controller: controller ?? this.controller,
      userLocation: userLocation ?? this.userLocation,
      collectionPoints: collectionPoints ?? this.collectionPoints,
      selectedPointId: selectedPointId ?? this.selectedPointId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    controller,
    userLocation,
    collectionPoints,
    selectedPointId,
    errorMessage,
  ];
}