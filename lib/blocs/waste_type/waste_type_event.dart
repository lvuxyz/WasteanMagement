import 'package:equatable/equatable.dart';

abstract class WasteTypeEvent extends Equatable {
  const WasteTypeEvent();

  @override
  List<Object?> get props => [];
}

class LoadWasteTypes extends WasteTypeEvent {}

class SearchWasteTypes extends WasteTypeEvent {
  final String query;

  const SearchWasteTypes(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterWasteTypesByCategory extends WasteTypeEvent {
  final String category;

  const FilterWasteTypesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SelectWasteType extends WasteTypeEvent {
  final int wasteTypeId;

  const SelectWasteType(this.wasteTypeId);

  @override
  List<Object?> get props => [wasteTypeId];
}

class AddToRecyclingPlan extends WasteTypeEvent {
  final int wasteTypeId;

  const AddToRecyclingPlan(this.wasteTypeId);

  @override
  List<Object?> get props => [wasteTypeId];
}

class LoadWasteTypeDetails extends WasteTypeEvent {
  final int wasteTypeId;

  const LoadWasteTypeDetails(this.wasteTypeId);

  @override
  List<Object?> get props => [wasteTypeId];
}

class LoadWasteTypeDetailsWithAvailablePoints extends WasteTypeEvent {
  final int wasteTypeId;

  const LoadWasteTypeDetailsWithAvailablePoints(this.wasteTypeId);

  @override
  List<Object?> get props => [wasteTypeId];
}