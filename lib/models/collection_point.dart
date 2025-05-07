class CollectionPoint {
  final int id;
  final String name;
  final String address;
  final double? distance;
  final String? operatingHours;
  final String? status;
  final int? capacity;
  final int? currentLoad;

  CollectionPoint({
    required this.id,
    required this.name,
    required this.address,
    this.distance,
    this.operatingHours,
    this.status,
    this.capacity,
    this.currentLoad,
  });

  factory CollectionPoint.fromJson(Map<String, dynamic> json) {
    return CollectionPoint(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      distance: json['distance']?.toDouble(),
      operatingHours: json['operating_hours'],
      status: json['status'],
      capacity: json['capacity'],
      currentLoad: json['current_load'],
    );
  }
} 