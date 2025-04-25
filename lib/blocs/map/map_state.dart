import 'package:equatable/equatable.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MapState extends Equatable {
  final bool isLoading;
  final LocationData? userLocation;
  final List<Map<String, dynamic>> collectionPoints;
  final int? selectedPointId;
  final String? errorMessage;
  final MapboxMapController? controller;

  const MapState({
    this.isLoading = false,
    this.userLocation,
    this.collectionPoints = const [],
    this.selectedPointId,
    this.errorMessage,
    this.controller,
  });

  MapState copyWith({
    bool? isLoading,
    LocationData? userLocation,
    List<Map<String, dynamic>>? collectionPoints,
    int? selectedPointId,
    String? errorMessage,
    MapboxMapController? controller,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      userLocation: userLocation ?? this.userLocation,
      collectionPoints: collectionPoints ?? this.collectionPoints,
      selectedPointId: selectedPointId ?? this.selectedPointId,
      errorMessage: errorMessage,
      controller: controller ?? this.controller,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    userLocation,
    collectionPoints,
    selectedPointId,
    errorMessage,
    controller,
  ];
}