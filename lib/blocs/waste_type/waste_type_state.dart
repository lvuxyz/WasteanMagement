import 'package:equatable/equatable.dart';
import '../../models/waste_type_model.dart';
import '../../models/collection_point_model.dart';

abstract class WasteTypeState extends Equatable {
  const WasteTypeState();

  @override
  List<Object?> get props => [];
}

class WasteTypeInitial extends WasteTypeState {}

class WasteTypeLoading extends WasteTypeState {
  final bool isDeleting;
  final int? deletingId;
  final bool isUpdating;
  final int? updatingId;
  final bool isCreating;

  const WasteTypeLoading({
    this.isDeleting = false,
    this.deletingId,
    this.isUpdating = false,
    this.updatingId,
    this.isCreating = false,
  });

  @override
  List<Object?> get props => [isDeleting, deletingId, isUpdating, updatingId, isCreating];
}

class CollectionPointsLoading extends WasteTypeState {}

class CollectionPointsError extends WasteTypeState {
  final String message;
  
  const CollectionPointsError(this.message);
  
  @override
  List<Object> get props => [message];
}

class WasteTypeLoaded extends WasteTypeState {
  final List<WasteType> wasteTypes;
  final List<WasteType> filteredWasteTypes;
  final String searchQuery;
  final String selectedCategory;
  final int? selectedWasteTypeId;

  const WasteTypeLoaded({
    required this.wasteTypes,
    required this.filteredWasteTypes,
    this.searchQuery = '',
    this.selectedCategory = '',
    this.selectedWasteTypeId,
  });

  @override
  List<Object?> get props => [wasteTypes, filteredWasteTypes, searchQuery, selectedCategory, selectedWasteTypeId];

  WasteTypeLoaded copyWith({
    List<WasteType>? wasteTypes,
    List<WasteType>? filteredWasteTypes,
    String? searchQuery,
    String? selectedCategory,
    int? selectedWasteTypeId,
  }) {
    return WasteTypeLoaded(
      wasteTypes: wasteTypes ?? this.wasteTypes,
      filteredWasteTypes: filteredWasteTypes ?? this.filteredWasteTypes,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedWasteTypeId: selectedWasteTypeId ?? this.selectedWasteTypeId,
    );
  }
}

class WasteTypeDetailLoaded extends WasteTypeState {
  final WasteType wasteType;
  final List<CollectionPoint> collectionPoints;
  final List<CollectionPoint>? allCollectionPoints;

  const WasteTypeDetailLoaded({
    required this.wasteType,
    required this.collectionPoints,
    this.allCollectionPoints,
  });

  @override
  List<Object?> get props => [wasteType, collectionPoints, allCollectionPoints];
}

class WasteTypeCreated extends WasteTypeState {
  final WasteType wasteType;
  final String message;

  const WasteTypeCreated({
    required this.wasteType,
    this.message = 'Đã tạo loại rác thành công',
  });

  @override
  List<Object?> get props => [wasteType, message];
}

class WasteTypeUpdated extends WasteTypeState {
  final WasteType wasteType;
  final String message;

  const WasteTypeUpdated({
    required this.wasteType,
    this.message = 'Đã cập nhật loại rác thành công',
  });

  @override
  List<Object?> get props => [wasteType, message];
}

class WasteTypeDeleted extends WasteTypeState {
  final int wasteTypeId;
  final String message;

  const WasteTypeDeleted({
    required this.wasteTypeId,
    this.message = 'Đã xóa loại rác thành công',
  });

  @override
  List<Object?> get props => [wasteTypeId, message];
}

class CollectionPointLinked extends WasteTypeState {
  final int wasteTypeId;
  final int collectionPointId;

  const CollectionPointLinked({
    required this.wasteTypeId,
    required this.collectionPointId,
  });

  @override
  List<Object?> get props => [wasteTypeId, collectionPointId];
}

class CollectionPointUnlinked extends WasteTypeState {
  final int wasteTypeId;
  final int collectionPointId;

  const CollectionPointUnlinked({
    required this.wasteTypeId,
    required this.collectionPointId,
  });

  @override
  List<Object?> get props => [wasteTypeId, collectionPointId];
}

class WasteTypeError extends WasteTypeState {
  final String message;

  const WasteTypeError(this.message);

  @override
  List<Object?> get props => [message];
}

class RecyclingPlanUpdated extends WasteTypeState {
  final String message;

  const RecyclingPlanUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class WasteTypeCollectionPointsLoaded extends WasteTypeState {
  final WasteType wasteType;
  final List<CollectionPoint> linkedCollectionPoints;
  final List<CollectionPoint> availableCollectionPoints;
  final String linkedSearchQuery;
  final String availableSearchQuery;

  const WasteTypeCollectionPointsLoaded({
    required this.wasteType,
    required this.linkedCollectionPoints,
    required this.availableCollectionPoints,
    required this.linkedSearchQuery,
    required this.availableSearchQuery,
  });

  @override
  List<Object?> get props => [
    wasteType,
    linkedCollectionPoints,
    availableCollectionPoints,
    linkedSearchQuery,
    availableSearchQuery,
  ];

  WasteTypeCollectionPointsLoaded copyWith({
    WasteType? wasteType,
    List<CollectionPoint>? linkedCollectionPoints,
    List<CollectionPoint>? availableCollectionPoints,
    String? linkedSearchQuery,
    String? availableSearchQuery,
  }) {
    return WasteTypeCollectionPointsLoaded(
      wasteType: wasteType ?? this.wasteType,
      linkedCollectionPoints: linkedCollectionPoints ?? this.linkedCollectionPoints,
      availableCollectionPoints: availableCollectionPoints ?? this.availableCollectionPoints,
      linkedSearchQuery: linkedSearchQuery ?? this.linkedSearchQuery,
      availableSearchQuery: availableSearchQuery ?? this.availableSearchQuery,
    );
  }
}

class WasteTypesForCollectionPointLoaded extends WasteTypeState {
  final int collectionPointId;
  final String collectionPointName;
  final List<WasteType> wasteTypes;

  const WasteTypesForCollectionPointLoaded({
    required this.collectionPointId,
    required this.collectionPointName,
    required this.wasteTypes,
  });

  @override
  List<Object?> get props => [collectionPointId, collectionPointName, wasteTypes];
}

class WasteTypeAddedToCollectionPoint extends WasteTypeState {
  final int collectionPointId;
  final int wasteTypeId;
  final String message;

  const WasteTypeAddedToCollectionPoint({
    required this.collectionPointId,
    required this.wasteTypeId,
    this.message = 'Đã thêm loại rác vào điểm thu gom thành công',
  });

  @override
  List<Object?> get props => [collectionPointId, wasteTypeId, message];
}