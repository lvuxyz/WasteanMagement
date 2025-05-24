import 'package:equatable/equatable.dart';
import '../../models/recycling_record_model.dart';
import '../../models/recycling_statistics_model.dart';

abstract class RecyclingProgressState extends Equatable {
  const RecyclingProgressState();

  @override
  List<Object?> get props => [];
}

class RecyclingProgressInitial extends RecyclingProgressState {}

class RecyclingProgressLoading extends RecyclingProgressState {}

class RecyclingProgressLoaded extends RecyclingProgressState {
  final List<RecyclingRecord> records;
  final List<RecyclingRecord> filteredRecords;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedWasteTypeId;
  final Map<String, double> wasteTypeQuantities;
  final double totalWeight;
  final RecyclingStatisticsData? statistics;

  const RecyclingProgressLoaded({
    required this.records,
    required this.filteredRecords,
    this.startDate,
    this.endDate,
    this.selectedWasteTypeId,
    required this.wasteTypeQuantities,
    required this.totalWeight,
    this.statistics,
  });

  @override
  List<Object?> get props => [
    records, 
    filteredRecords, 
    startDate, 
    endDate, 
    selectedWasteTypeId, 
    wasteTypeQuantities,
    totalWeight,
    statistics,
  ];

  RecyclingProgressLoaded copyWith({
    List<RecyclingRecord>? records,
    List<RecyclingRecord>? filteredRecords,
    DateTime? startDate,
    DateTime? endDate,
    String? selectedWasteTypeId,
    Map<String, double>? wasteTypeQuantities,
    double? totalWeight,
    RecyclingStatisticsData? statistics,
  }) {
    return RecyclingProgressLoaded(
      records: records ?? this.records,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedWasteTypeId: selectedWasteTypeId ?? this.selectedWasteTypeId,
      wasteTypeQuantities: wasteTypeQuantities ?? this.wasteTypeQuantities,
      totalWeight: totalWeight ?? this.totalWeight,
      statistics: statistics ?? this.statistics,
    );
  }
}

class RecyclingStatisticsLoading extends RecyclingProgressState {}

class RecyclingStatisticsLoaded extends RecyclingProgressState {
  final RecyclingStatisticsData statistics;

  const RecyclingStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class RecyclingProgressError extends RecyclingProgressState {
  final String message;

  const RecyclingProgressError(this.message);

  @override
  List<Object?> get props => [message];
} 