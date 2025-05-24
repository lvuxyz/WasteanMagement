import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/recycling_record_model.dart';
import '../../repositories/recycling_progress_repository.dart';
import 'recycling_progress_event.dart';
import 'recycling_progress_state.dart';
import 'dart:developer' as developer;

class RecyclingProgressBloc extends Bloc<RecyclingProgressEvent, RecyclingProgressState> {
  final RecyclingProgressRepository repository;

  RecyclingProgressBloc({required this.repository}) : super(RecyclingProgressInitial()) {
    on<LoadRecyclingProgress>(_onLoadRecyclingProgress);
    on<FetchRecyclingStatistics>(_onFetchRecyclingStatistics);
    on<FilterRecyclingProgressByTimeRange>(_onFilterByTimeRange);
    on<FilterRecyclingProgressByWasteType>(_onFilterByWasteType);
  }

  Future<void> _onLoadRecyclingProgress(
    LoadRecyclingProgress event,
    Emitter<RecyclingProgressState> emit,
  ) async {
    emit(RecyclingProgressLoading());
    try {
      final records = await repository.getRecyclingRecords();
      final wasteTypeQuantities = repository.calculateWasteTypeQuantities(records);
      final totalWeight = repository.calculateTotalWeight(records);
      
      emit(RecyclingProgressLoaded(
        records: records,
        filteredRecords: records,
        wasteTypeQuantities: wasteTypeQuantities,
        totalWeight: totalWeight,
      ));
    } catch (e) {
      emit(RecyclingProgressError('Không thể tải dữ liệu tái chế: $e'));
    }
  }

  Future<void> _onFetchRecyclingStatistics(
    FetchRecyclingStatistics event,
    Emitter<RecyclingProgressState> emit,
  ) async {
    if (state is RecyclingProgressLoaded) {
      final currentState = state as RecyclingProgressLoaded;
      emit(RecyclingStatisticsLoading());
      
      try {
        developer.log('Đang lấy dữ liệu thống kê từ API...');
        final statistics = await repository.getRecyclingStatistics(
          fromDate: event.fromDate,
          toDate: event.toDate,
          wasteTypeId: event.wasteTypeId,
        );
        
        developer.log('Đã nhận được dữ liệu thống kê: ${statistics.totals.totalProcesses} quy trình');
        
        // If we're already in a loaded state, update with new statistics
        emit(currentState.copyWith(statistics: statistics));
      } catch (e) {
        developer.log('Lỗi khi lấy thống kê: $e');
        emit(RecyclingProgressError('Không thể tải dữ liệu thống kê: $e'));
        // Revert back to previous state if error occurs
        emit(currentState);
      }
    } else {
      // If we're not already in a loaded state, create a basic loaded state with statistics
      emit(RecyclingStatisticsLoading());
      
      try {
        final statistics = await repository.getRecyclingStatistics(
          fromDate: event.fromDate,
          toDate: event.toDate,
          wasteTypeId: event.wasteTypeId,
        );
        
        emit(RecyclingProgressLoaded(
          records: const [],
          filteredRecords: const [],
          wasteTypeQuantities: const {},
          totalWeight: 0,
          statistics: statistics,
        ));
      } catch (e) {
        developer.log('Lỗi khi lấy thống kê: $e');
        emit(RecyclingProgressError('Không thể tải dữ liệu thống kê: $e'));
      }
    }
  }

  void _onFilterByTimeRange(
    FilterRecyclingProgressByTimeRange event,
    Emitter<RecyclingProgressState> emit,
  ) {
    if (state is RecyclingProgressLoaded) {
      final currentState = state as RecyclingProgressLoaded;
      final startDate = event.startDate;
      final endDate = event.endDate;
      
      final filteredRecords = repository.filterByDateRange(
        currentState.records, 
        startDate, 
        endDate
      );
      
      final wasteTypeQuantities = repository.calculateWasteTypeQuantities(filteredRecords);
      final totalWeight = repository.calculateTotalWeight(filteredRecords);
      
      emit(currentState.copyWith(
        filteredRecords: filteredRecords,
        startDate: startDate,
        endDate: endDate,
        wasteTypeQuantities: wasteTypeQuantities,
        totalWeight: totalWeight,
      ));
    }
  }

  void _onFilterByWasteType(
    FilterRecyclingProgressByWasteType event,
    Emitter<RecyclingProgressState> emit,
  ) {
    if (state is RecyclingProgressLoaded) {
      final currentState = state as RecyclingProgressLoaded;
      final wasteTypeId = event.wasteTypeId;
      
      List<RecyclingRecord> filteredRecords;
      
      if (wasteTypeId.isEmpty) {
        // If no waste type selected, show all records
        filteredRecords = currentState.records;
      } else {
        // Filter by waste type
        filteredRecords = repository.filterByWasteType(
          currentState.records, 
          wasteTypeId,
        );
      }
      
      // Apply date filter if already set
      if (currentState.startDate != null && currentState.endDate != null) {
        filteredRecords = repository.filterByDateRange(
          filteredRecords,
          currentState.startDate!,
          currentState.endDate!,
        );
      }
      
      final wasteTypeQuantities = repository.calculateWasteTypeQuantities(filteredRecords);
      final totalWeight = repository.calculateTotalWeight(filteredRecords);
      
      emit(currentState.copyWith(
        filteredRecords: filteredRecords,
        selectedWasteTypeId: wasteTypeId.isEmpty ? null : wasteTypeId,
        wasteTypeQuantities: wasteTypeQuantities,
        totalWeight: totalWeight,
      ));
    }
  }
} 