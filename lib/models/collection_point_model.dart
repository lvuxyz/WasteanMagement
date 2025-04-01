class CollectionPoint {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String operatingHours;
  final double capacity;
  final double currentLoad;
  final String status;

  CollectionPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.operatingHours = '',
    this.capacity = 0,
    this.currentLoad = 0,
    this.status = 'active',
  });

  factory CollectionPoint.fromJson(Map<String, dynamic> json) {
    return CollectionPoint(
      id: json['collection_point_id'],
      name: json['name'],
      address: json['address'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      operatingHours: json['operating_hours'] ?? '',
      capacity: json['capacity'] != null ? (json['capacity'] as num).toDouble() : 0,
      currentLoad: json['current_load'] != null ? (json['current_load'] as num).toDouble() : 0,
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collection_point_id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'operating_hours': operatingHours,
      'capacity': capacity,
      'current_load': currentLoad,
      'status': status,
    };
  }
} 