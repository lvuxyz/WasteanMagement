class User {
  final String id;
  final String email;
  final String username;
  final String fullName;
  
  User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
    };
  }
} 