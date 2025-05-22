import 'package:equatable/equatable.dart';

abstract class RecyclingProgressEvent extends Equatable {
  const RecyclingProgressEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecyclingProgress extends RecyclingProgressEvent {
  const LoadRecyclingProgress();
}

class FetchRecyclingStatistics extends RecyclingProgressEvent {
  final String fromDate;
  final String toDate;
  final String? wasteTypeId;

  const FetchRecyclingStatistics({
    required this.fromDate,
    required this.toDate,
    this.wasteTypeId,
  });

  @override
  List<Object?> get props => [fromDate, toDate, wasteTypeId];
}

class FilterRecyclingProgressByTimeRange extends RecyclingProgressEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FilterRecyclingProgressByTimeRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class FilterRecyclingProgressByWasteType extends RecyclingProgressEvent {
  final String wasteTypeId;

  const FilterRecyclingProgressByWasteType({
    required this.wasteTypeId,
  });

  @override
  List<Object?> get props => [wasteTypeId];
} 