import 'package:equatable/equatable.dart';

class User extends Equatable {
  final dynamic id;
  final String email;
  final String username;
  final String fullName;
  final String? phone;
  final String? address;
  final String? status;
  final DateTime? createdAt;
  final List<String>? roles;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.phone,
    this.address,
    this.status = 'active',
    this.createdAt,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : null,
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
      'created_at': createdAt?.toIso8601String(),
      'roles': roles,
    };
  }

  @override
  List<Object?> get props => [id, email, username, fullName, phone, address, status, createdAt, roles];
}