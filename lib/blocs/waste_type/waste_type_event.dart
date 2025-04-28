import 'package:equatable/equatable.dart';
import '../../models/waste_type_model.dart';

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

class DeleteWasteType extends WasteTypeEvent {
  final int wasteTypeId;

  const DeleteWasteType(this.wasteTypeId);

  @override
  List<Object?> get props => [wasteTypeId];
}

class LinkCollectionPoint extends WasteTypeEvent {
  final int wasteTypeId;
  final int collectionPointId;

  const LinkCollectionPoint({
    required this.wasteTypeId,
    required this.collectionPointId,
  });

  @override
  List<Object?> get props => [wasteTypeId, collectionPointId];
}

class UnlinkCollectionPoint extends WasteTypeEvent {
  final int wasteTypeId;
  final int collectionPointId;

  const UnlinkCollectionPoint({
    required this.wasteTypeId,
    required this.collectionPointId,
  });

  @override
  List<Object?> get props => [wasteTypeId, collectionPointId];
}

class CreateWasteType extends WasteTypeEvent {
  final WasteType wasteType;

  const CreateWasteType(this.wasteType);

  @override
  List<Object?> get props => [wasteType];
}

class UpdateWasteType extends WasteTypeEvent {
  final WasteType wasteType;

  const UpdateWasteType(this.wasteType);

  @override
  List<Object?> get props => [wasteType];
}