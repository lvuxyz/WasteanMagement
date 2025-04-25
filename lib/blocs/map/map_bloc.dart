import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import '../../services/mapbox_service.dart';
import 'map_event.dart';
import 'map_state.dart';
import 'dart:ui' as ui;

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapboxService mapboxService;

  MapBloc({required this.mapboxService}) : super(const MapState()) {
    on<MapInitialized>(_onMapInitialized);
    on<LoadUserLocation>(_onLoadUserLocation);
    on<LoadCollectionPoints>(_onLoadCollectionPoints);
    on<SelectCollectionPoint>(_onSelectCollectionPoint);
  }

  void _onMapInitialized(MapInitialized event, Emitter<MapState> emit) {
    emit(state.copyWith(controller: event.controller));
    add(LoadUserLocation());
    add(LoadCollectionPoints());
  }

  Future<void> _onLoadUserLocation(LoadUserLocation event, Emitter<MapState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final location = await mapboxService.getCurrentLocation();

      if (location != null && state.controller != null) {
        await state.controller!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(location.latitude!, location.longitude!),
            15.0,
          ),
        );

        // Thêm marker cho vị trí người dùng
        await state.controller!.addSymbol(SymbolOptions(
          geometry: LatLng(location.latitude!, location.longitude!),
          iconImage: 'marker-15',
          iconSize: 2.0,
        ));
      }

      emit(state.copyWith(
        isLoading: false,
        userLocation: location,
      ));
    } catch (e) {
      developer.log('Lỗi khi lấy vị trí người dùng: $e', error: e);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể lấy vị trí của bạn. Vui lòng thử lại sau.',
      ));
    }
  }

  Future<void> _onLoadCollectionPoints(LoadCollectionPoints event, Emitter<MapState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Mô phỏng việc lấy dữ liệu từ API
      await Future.delayed(const Duration(seconds: 1));

      // Dữ liệu mẫu từ file home_screen.dart
      final mockCollectionPoints = [
        {
          'id': 1,
          'name': 'Điểm thu gom Nguyễn Trãi',
          'address': 'Số 123 Nguyễn Trãi, Quận 1, TP.HCM',
          'latitude': 10.7731,
          'longitude': 106.6880,
          'distance': 2.5,
          'operating_hours': '08:00 - 17:00',
          'status': 'active',
          'capacity': 1000,
          'current_load': 450,
        },
        {
          'id': 2,
          'name': 'Điểm thu gom Lê Duẩn',
          'address': 'Số 456 Lê Duẩn, Quận 3, TP.HCM',
          'latitude': 10.7839,
          'longitude': 106.7005,
          'distance': 3.7,
          'operating_hours': '07:30 - 18:00',
          'status': 'active',
          'capacity': 800,
          'current_load': 650,
        },
        {
          'id': 3,
          'name': 'Điểm thu gom Nguyễn Đình Chiểu',
          'address': 'Số 789 Nguyễn Đình Chiểu, Quận 3, TP.HCM',
          'latitude': 10.7765,
          'longitude': 106.6902,
          'distance': 4.2,
          'operating_hours': '08:00 - 17:30',
          'status': 'active',
          'capacity': 1200,
          'current_load': 300,
        },
      ];

      // Thêm markers cho điểm thu gom
      if (state.controller != null) {
        for (final point in mockCollectionPoints) {
          await state.controller!.addSymbol(SymbolOptions(
            geometry: LatLng(point['latitude'] as double, point['longitude'] as double),
            iconImage: 'marker-15',
            iconColor: '#7AB547',
            iconSize: 1.5,
            textField: point['name'] as String,
            textOffset: const ui.Offset(0, 1.5),  // Sử dụng ui.Offset
            textColor: '#000000',
            textSize: 12.0,
          ));
        }
      }

      emit(state.copyWith(
        isLoading: false,
        collectionPoints: mockCollectionPoints,
      ));
    } catch (e) {
      developer.log('Lỗi khi tải điểm thu gom: $e', error: e);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải điểm thu gom. Vui lòng thử lại sau.',
      ));
    }
  }

  void _onSelectCollectionPoint(SelectCollectionPoint event, Emitter<MapState> emit) {
    // Tìm điểm thu gom được chọn
    final selectedPoint = state.collectionPoints.firstWhere(
          (point) => point['id'] == event.pointId,
      orElse: () => {},
    );

    if (selectedPoint.isNotEmpty && state.controller != null) {
      // Di chuyển camera đến điểm được chọn
      state.controller!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(selectedPoint['latitude'], selectedPoint['longitude']),
          15.0,
        ),
      );

      emit(state.copyWith(selectedPointId: event.pointId));
    }
  }
}