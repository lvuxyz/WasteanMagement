import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? phone;
  final String? address;
  final String status;
  final DateTime createdAt;
  final List<String> roles;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.phone,
    this.address,
    required this.status,
    required this.createdAt,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, email, username, fullName, phone, address, status, createdAt];
}