import 'package:equatable/equatable.dart';

class CollectionPoint extends Equatable {
  final int collectionPointId;
  final String name;
  final String address;
  final String? description;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String? phone;
  final String? email;
  final String? website;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final String status;
  final double? currentLoad;
  final int capacity;
  final String operatingHours;

  const CollectionPoint({
    required this.collectionPointId,
    required this.name,
    required this.address,
    this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.phone,
    this.email,
    this.website,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    required this.status,
    this.currentLoad,
    required this.capacity,
    required this.operatingHours,
  });

  // Factory constructor to create from API response
  factory CollectionPoint.fromJson(Map<String, dynamic> json) {
    return CollectionPoint(
      collectionPointId: json['collection_point_id'] ?? json['id'],
      name: json['name'],
      address: json['address'],
      description: json['description'],
      latitude: (json['latitude'] is double) 
          ? json['latitude'] 
          : double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: (json['longitude'] is double) 
          ? json['longitude'] 
          : double.tryParse(json['longitude'].toString()) ?? 0.0,
      imageUrl: json['imageUrl'] ?? json['image_url'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      isActive: json['isActive'] ?? (json['status'] == 'active'),
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
      status: json['status'] ?? 'active',
      currentLoad: json['current_load'] != null 
          ? (json['current_load'] is double) 
              ? json['current_load'] 
              : double.tryParse(json['current_load'].toString())
          : null,
      capacity: (json['capacity'] is int) 
          ? json['capacity'] 
          : int.tryParse(json['capacity'].toString()) ?? 0,
      operatingHours: json['operating_hours'] ?? json['operatingHours'] ?? '8:00-17:00',
    );
  }

  // For compatibility with older code
  int get id => collectionPointId;

  @override
  List<Object?> get props => [
    collectionPointId, name, address, description, latitude, longitude, imageUrl,
    phone, email, website, isActive, createdAt, updatedAt, status,
    currentLoad, capacity, operatingHours
  ];
}

class CollectionPointsResponse {
  final String status;
  final int results;
  final List<CollectionPoint> collectionPoints;

  CollectionPointsResponse({
    required this.status,
    required this.results,
    required this.collectionPoints,
  });

  factory CollectionPointsResponse.fromJson(Map<String, dynamic> json) {
    final collectionPointsJson = json['data']['collectionPoints'] as List;
    return CollectionPointsResponse(
      status: json['status'],
      results: json['results'],
      collectionPoints: collectionPointsJson
          .map((point) => CollectionPoint.fromJson(point))
          .toList(),
    );
  }
} 