import 'package:equatable/equatable.dart';

abstract class RecyclingProgressEvent extends Equatable {
  const RecyclingProgressEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecyclingProgress extends RecyclingProgressEvent {
  const LoadRecyclingProgress();
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