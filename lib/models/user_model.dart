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
  final Map<String, dynamic>? rawProfileData;

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
    this.rawProfileData,
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
      rawProfileData: json['rawProfileData'] as Map<String, dynamic>?,
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
      'rawProfileData': rawProfileData,
    };
  }

  bool get isAdmin {
    if (roles == null || roles!.isEmpty) {
      print('[DEBUG] isAdmin check - roles is null or empty: ${roles}');
      // Mặc định là false nếu không có roles
      return false;
    }
    
    // Log all roles for debugging
    print('[DEBUG] isAdmin check - roles: ${roles}');
    
    // Check if any admin role exists - case insensitive
    final hasAdminRole = roles!.any((role) => 
      role.toLowerCase() == 'admin' || 
      role.toLowerCase() == 'administrator');
    
    print('[DEBUG] isAdmin result: $hasAdminRole');
    
    return hasAdminRole;
  }

  @override
  List<Object?> get props => [id, email, username, fullName, phone, address, status, createdAt, roles, rawProfileData];
}