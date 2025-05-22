import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/collection_point_repository.dart';
import '../../models/collection_point.dart';
import 'collection_point_event.dart';
import 'collection_point_state.dart';

class CollectionPointBloc extends Bloc<CollectionPointEvent, CollectionPointState> {
  final CollectionPointRepository repository;

  CollectionPointBloc({required this.repository}) : super(CollectionPointInitial()) {
    on<LoadCollectionPoints>(_onLoadCollectionPoints);
    on<LoadCollectionPointDetails>(_onLoadCollectionPointDetails);
    on<CreateCollectionPoint>(_onCreateCollectionPoint);
    on<SearchCollectionPoints>(_onSearchCollectionPoints);
  }

  Future<void> _onLoadCollectionPoints(
      LoadCollectionPoints event,
      Emitter<CollectionPointState> emit,
      ) async {
    emit(const CollectionPointLoading());
    try {
      final collectionPoints = await repository.getAllCollectionPoints();
      emit(CollectionPointsLoaded(
        collectionPoints: collectionPoints,
        filteredCollectionPoints: collectionPoints,
      ));
    } catch (e) {
      emit(CollectionPointError('Không thể tải danh sách điểm thu gom: $e'));
    }
  }

  Future<void> _onLoadCollectionPointDetails(
      LoadCollectionPointDetails event,
      Emitter<CollectionPointState> emit,
      ) async {
    emit(const CollectionPointLoading());
    try {
      final collectionPoint = await repository.getCollectionPointById(event.collectionPointId);
      if (collectionPoint != null) {
        emit(CollectionPointDetailLoaded(collectionPoint: collectionPoint));
      } else {
        emit(const CollectionPointError('Không tìm thấy điểm thu gom này'));
      }
    } catch (e) {
      emit(CollectionPointError('Không thể tải chi tiết điểm thu gom: $e'));
    }
  }

  Future<void> _onCreateCollectionPoint(
      CreateCollectionPoint event,
      Emitter<CollectionPointState> emit,
      ) async {
    emit(const CollectionPointLoading(isCreating: true));
    try {
      final collectionPoint = await repository.createCollectionPoint(
        name: event.name,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
        operatingHours: event.operatingHours,
        capacity: event.capacity,
        status: event.status,
      );
      
      if (collectionPoint != null) {
        emit(CollectionPointCreated(collectionPoint: collectionPoint));
        // Load lại danh sách sau khi tạo thành công
        add(LoadCollectionPoints());
      } else {
        emit(const CollectionPointError('Không thể tạo điểm thu gom'));
      }
    } catch (e) {
      developer.log('Lỗi khi tạo điểm thu gom trong bloc: $e', error: e);
      emit(CollectionPointError('Không thể tạo điểm thu gom: $e'));
    }
  }

  void _onSearchCollectionPoints(
      SearchCollectionPoints event,
      Emitter<CollectionPointState> emit,
      ) {
    if (state is CollectionPointsLoaded) {
      final currentState = state as CollectionPointsLoaded;
      final query = event.query.toLowerCase();

      List<CollectionPoint> filteredList;
      
      if (query.isEmpty) {
        filteredList = currentState.collectionPoints;
      } else {
        filteredList = currentState.collectionPoints
            .where((point) => 
                point.name.toLowerCase().contains(query) ||
                point.address.toLowerCase().contains(query))
            .toList();
      }

      emit(currentState.copyWith(
        filteredCollectionPoints: filteredList,
        searchQuery: query,
      ));
    }
  }
} 