import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../utils/app_colors.dart';
import '../../services/mapbox_service.dart';
import 'map_event.dart';
import 'map_state.dart';

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
        // Tạo cameraOptions cho API mới
        final cameraOptions = CameraOptions(
          center: Point(
            coordinates: Position(
              location.longitude!,
              location.latitude!,
            ),
          ),
          zoom: 15.0,
        );

        // Sử dụng flyTo với đúng tham số
        await state.controller!.flyTo(cameraOptions, null);  // Thêm tham số thứ hai là null

        // Thêm marker cho vị trí người dùng
        final pointAnnotationManager = await state.controller!.annotations.createPointAnnotationManager();

        // Tạo hình ảnh biểu tượng cho marker
        final Uint8List markerIcon = await _createCustomMarkerIcon(Colors.blue, 24);

        await pointAnnotationManager.create(
          PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(
                location.longitude!,
                location.latitude!,
              ),
            ),
            image: markerIcon,
            iconSize: 0.5,
          ),
        );
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
        final pointAnnotationManager = await state.controller!.annotations.createPointAnnotationManager();

        // Tạo biểu tượng cho điểm thu gom
        final Uint8List markerIcon = await _createCustomMarkerIcon(AppColors.primaryGreen, 32);

        for (final point in mockCollectionPoints) {
          await pointAnnotationManager.create(
            PointAnnotationOptions(
              geometry: Point(
                coordinates: Position(
                  point['longitude'] as double,
                  point['latitude'] as double,
                ),
              ),
              textField: point['name'] as String,
              textOffset: [0.0, 1.5],
              textColor: Colors.black.value,
              textSize: 12.0,
              image: markerIcon, // sử dụng 'image' thay vì 'iconImage'
              iconSize: 0.5,
            ),
          );
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
      // Di chuyển camera đến điểm được chọn - thêm tham số thứ hai là null
      state.controller!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(
                selectedPoint['longitude'] as double,
                selectedPoint['latitude'] as double,
              ),
            ),
            zoom: 15.0,
          ),
          null
      );

      emit(state.copyWith(selectedPointId: event.pointId));
    }
  }

  // Phương thức hỗ trợ tạo biểu tượng tùy chỉnh
  Future<Uint8List> _createCustomMarkerIcon(Color color, double size) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Vẽ hình tròn làm biểu tượng
    canvas.drawCircle(Offset(size/2, size/2), size/2 - 2, paint);
    canvas.drawCircle(Offset(size/2, size/2), size/2 - 2, borderPaint);

    final img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}