import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../utils/app_colors.dart';
import '../../services/mapbox_service.dart';
import '../../repositories/collection_point_repository.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapboxService mapboxService;
  final CollectionPointRepository collectionPointRepository;

  MapBloc({
    required this.mapboxService, 
    required this.collectionPointRepository
  }) : super(const MapState()) {
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
        try {
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
          try {
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
          } catch (annotationError) {
            developer.log('Lỗi khi tạo annotation marker: $annotationError', error: annotationError);
            // Tiếp tục xử lý mà không hiển thị marker
          }
        } catch (mapError) {
          developer.log('Lỗi khi cập nhật camera map: $mapError', error: mapError);
          // Tiếp tục xử lý mà không di chuyển camera
        }
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
      // Lấy dữ liệu từ repository
      final collectionPoints = await collectionPointRepository.getAllCollectionPoints();

      // Chuyển đổi sang dạng Map và tính toán khoảng cách
      final List<Map<String, dynamic>> processedPoints = [];
      
      // Tính khoảng cách nếu có vị trí người dùng
      final userLocation = state.userLocation;
      
      for (var point in collectionPoints) {
        double distance = 0.0;
        if (userLocation != null) {
          // Tính khoảng cách từ vị trí người dùng đến điểm thu gom
          final userPosition = Position(userLocation.longitude!, userLocation.latitude!);
          final pointPosition = Position(point.longitude, point.latitude);
          distance = mapboxService.calculateDistance(userPosition, pointPosition) / 1000; // Chuyển đổi từ mét sang km
        }
        
        processedPoints.add({
          'id': point.collectionPointId,
          'name': point.name,
          'address': point.address,
          'latitude': point.latitude,
          'longitude': point.longitude,
          'distance': distance.toStringAsFixed(1),
          'operating_hours': point.operatingHours,
          'status': point.status,
          'capacity': point.capacity,
          'current_load': point.currentLoad ?? 0.0,
        });
      }
      
      // Thêm markers cho điểm thu gom
      if (state.controller != null) {
        try {
          final pointAnnotationManager = await state.controller!.annotations.createPointAnnotationManager();

          // Tạo biểu tượng cho điểm thu gom
          final Uint8List markerIcon = await _createCustomMarkerIcon(AppColors.primaryGreen, 32);

          // Xóa các markers cũ
          await pointAnnotationManager.deleteAll();

          // Thêm markers mới
          for (final point in processedPoints) {
            final options = PointAnnotationOptions(
              geometry: Point(
                coordinates: Position(
                  point['longitude'],
                  point['latitude'],
                ),
              ),
              image: markerIcon,
            );
            await pointAnnotationManager.create(options);
          }

          emit(state.copyWith(
            collectionPoints: processedPoints,
            isLoading: false,
          ));
        } catch (e) {
          developer.log('Error adding markers: $e', error: e);
          emit(state.copyWith(
            isLoading: false,
            errorMessage: 'Không thể hiển thị điểm thu gom trên bản đồ',
          ));
        }
      } else {
        emit(state.copyWith(
          collectionPoints: processedPoints,
          isLoading: false,
        ));
      }
    } catch (e) {
      developer.log('Error loading collection points: $e', error: e);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh sách điểm thu gom',
      ));
    }
  }

  void _onSelectCollectionPoint(SelectCollectionPoint event, Emitter<MapState> emit) {
    try {
      if (state.collectionPoints.isEmpty) {
        return;
      }

      final selectedPoint = state.collectionPoints.firstWhere(
        (point) => point['id'] == event.pointId,
        orElse: () => state.collectionPoints.first,
      );

      if (state.controller != null) {
        state.controller!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(
                selectedPoint['longitude'],
                selectedPoint['latitude'],
              ),
            ),
            zoom: 15.0,
          ),
          null,
        );
      }

      emit(state.copyWith(selectedPointId: selectedPoint['id']));
    } catch (e) {
      developer.log('Error selecting collection point: $e', error: e);
      emit(state.copyWith(
        errorMessage: 'Không thể hiển thị chi tiết điểm thu gom',
      ));
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