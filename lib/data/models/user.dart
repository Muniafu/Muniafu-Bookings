import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? birthDate;
  final String? location;
  final String? phone;
  final String? bio;
  

  User({
    required this.id,
    this.name = '',
    required this.email,
    this.role = 'user',
    required this.createdAt,
    required this.updatedAt,
    this.birthDate,
    this.location,
    this.phone,
    this.bio,
  });

  // Getter to check admin status
  bool get isAdmin => role == 'admin';

  // Named constructor for JSON parsing (generic)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Named constructor specifically for Firestore
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  // Convert to JSON for storage/serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  // CopyWith pattern for immutable updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  // Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        role.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}