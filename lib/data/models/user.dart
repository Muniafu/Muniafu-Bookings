import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin', 'user', or other roles // Derived from role
  final String? phone; // Optional field from first model
  final DateTime? createdAt;
  
  

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.createdAt,
  });

  // Getter to check admin status
  bool get isAdmin => role.toLowerCase() == 'admin';

  // Factory constructor for JSON parsing
  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '', // Null safety from second model
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user', // Default role
      phone: json['phone'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }


  // Alternative factory for Firestore (handles Timestamp)
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      phone: data['phone'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
  // Convert from JSON (for API calls)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '', // Null safety from second model
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user', // Default role
      phone: json['phone'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  // Helper for copying with modified fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static Future<User?> fromJsonAsync(Map<String, dynamic> data) async {
    if (data.isEmpty) return null;
    return User.fromMap(data);
  }
}