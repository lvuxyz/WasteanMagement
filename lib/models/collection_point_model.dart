import 'package:equatable/equatable.dart';

class CollectionPoint extends Equatable {
  final String id;
  final String name;
  final String address;
  final String description;
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
  final double current_load;
  final double capacity;
  final String operating_hours;

  const CollectionPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.phone,
    this.email,
    this.website,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    required this.status,
    required this.current_load,
    required this.capacity,
    required this.operating_hours,
  });

  // Phương thức sao chép với các thuộc tính mới
  CollectionPoint copyWith({
    String? id,
    String? name,
    String? address,
    String? description,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? phone,
    String? email,
    String? website,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    String? status,
    double? current_load,
    double? capacity,
    String? operating_hours,
  }) {
    return CollectionPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      current_load: current_load ?? this.current_load,
      capacity: capacity ?? this.capacity,
      operating_hours: operating_hours ?? this.operating_hours,
    );
  }

  // Factory constructor để tạo đối tượng từ JSON
  factory CollectionPoint.fromJson(Map<String, dynamic> json) {
    return CollectionPoint(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      description: json['description'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      imageUrl: json['imageUrl'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      status: json['status'],
      current_load: json['current_load'].toDouble(),
      capacity: json['capacity'].toDouble(),
      operating_hours: json['operating_hours'],
    );
  }

  // Phương thức để chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'phone': phone,
      'email': email,
      'website': website,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
      'current_load': current_load,
      'capacity': capacity,
      'operating_hours': operating_hours,
    };
  }

  @override
  List<Object?> get props => [
    id, name, address, description, latitude, longitude, imageUrl,
    phone, email, website, isActive, createdAt, updatedAt, status,
    current_load, capacity, operating_hours
  ];
} 