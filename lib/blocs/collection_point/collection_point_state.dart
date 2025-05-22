import 'package:equatable/equatable.dart';
import '../../models/collection_point.dart';

abstract class CollectionPointState extends Equatable {
  const CollectionPointState();

  @override
  List<Object?> get props => [];
}

class CollectionPointInitial extends CollectionPointState {}

class CollectionPointLoading extends CollectionPointState {
  final bool isCreating;

  const CollectionPointLoading({
    this.isCreating = false,
  });

  @override
  List<Object?> get props => [isCreating];
}

class CollectionPointsLoaded extends CollectionPointState {
  final List<CollectionPoint> collectionPoints;
  final List<CollectionPoint> filteredCollectionPoints;
  final String searchQuery;

  const CollectionPointsLoaded({
    required this.collectionPoints,
    required this.filteredCollectionPoints,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [collectionPoints, filteredCollectionPoints, searchQuery];

  CollectionPointsLoaded copyWith({
    List<CollectionPoint>? collectionPoints,
    List<CollectionPoint>? filteredCollectionPoints,
    String? searchQuery,
  }) {
    return CollectionPointsLoaded(
      collectionPoints: collectionPoints ?? this.collectionPoints,
      filteredCollectionPoints: filteredCollectionPoints ?? this.filteredCollectionPoints,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CollectionPointDetailsLoaded extends CollectionPointState {
  final CollectionPoint collectionPoint;

  const CollectionPointDetailsLoaded({
    required this.collectionPoint,
  });

  @override
  List<Object?> get props => [collectionPoint];
}

class CollectionPointDetailLoaded extends CollectionPointState {
  final CollectionPoint collectionPoint;

  const CollectionPointDetailLoaded({
    required this.collectionPoint,
  });

  @override
  List<Object?> get props => [collectionPoint];
}

class CollectionPointCreated extends CollectionPointState {
  final CollectionPoint collectionPoint;
  final String message;

  const CollectionPointCreated({
    required this.collectionPoint,
    this.message = 'Đã tạo điểm thu gom thành công',
  });

  @override
  List<Object?> get props => [collectionPoint, message];
}

class CollectionPointError extends CollectionPointState {
  final String message;

  const CollectionPointError(this.message);

  @override
  List<Object?> get props => [message];
} 