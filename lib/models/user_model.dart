class User {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? phone;
  final String? address;
  final String status;
  final DateTime createdAt;
  
  User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.phone,
    this.address,
    required this.status,
    required this.createdAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 

