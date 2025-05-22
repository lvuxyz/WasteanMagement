import 'package:equatable/equatable.dart';

abstract class CollectionPointEvent extends Equatable {
  const CollectionPointEvent();

  @override
  List<Object?> get props => [];
}

class LoadCollectionPoints extends CollectionPointEvent {}

class LoadCollectionPointDetails extends CollectionPointEvent {
  final int collectionPointId;

  const LoadCollectionPointDetails(this.collectionPointId);

  @override
  List<Object?> get props => [collectionPointId];
}

class CreateCollectionPoint extends CollectionPointEvent {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String operatingHours;
  final int capacity;
  final String status;

  const CreateCollectionPoint({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.operatingHours,
    required this.capacity,
    this.status = 'active',
  });

  @override
  List<Object?> get props => [name, address, latitude, longitude, operatingHours, capacity, status];
}

class SearchCollectionPoints extends CollectionPointEvent {
  final String query;

  const SearchCollectionPoints(this.query);

  @override
  List<Object?> get props => [query];
} 