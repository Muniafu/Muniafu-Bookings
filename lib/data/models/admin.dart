import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String id;
  final String name;
  final String email;
  final List<String> managedHotels; // From AdminModel
  final List<String> permissions; // New field for role permissions
  final DateTime? createdAt; // New field for tracking
  final bool isSuperAdmin; // New field for admin hierarchy

  Admin({
    required this.id,
    required this.name,
    required this.email,
    this.managedHotels = const [], // Default empty list
    this.permissions = const [], // Default empty list
    this.createdAt,
    this.isSuperAdmin = false,
  });

  // Check if admin manages a specific hotel (from AdminModel)
  bool managesHotel(String hotelId) => isSuperAdmin || managedHotels.contains(hotelId);

  // Check if admin has specific permission
  bool hasPermission(String permission) => 
      isSuperAdmin || permissions.contains(permission);

  // Factory constructor for JSON parsing (API responses)
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      managedHotels: List<String>.from(json['managedHotels'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      isSuperAdmin: json['isSuperAdmin'] ?? false,
    );
  }

  // Factory constructor for Firestore documents
  factory Admin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Admin(
      id: doc.id, // Use document ID from Firestore
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      managedHotels: List<String>.from(data['managedHotels'] ?? []),
      permissions: List<String>.from(data['permissions'] ?? []),
      createdAt: data['createdAt']?.toDate(),
      isSuperAdmin: data['isSuperAdmin'] ?? false,
    );
  }

  // Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (managedHotels.isNotEmpty) 'managedHotels': managedHotels,
      if (permissions.isNotEmpty) 'permissions': permissions,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (isSuperAdmin) 'isSuperAdmin': isSuperAdmin,
    };
  }

  // Convert to Map (for Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'managedHotels': managedHotels,
      'permissions': permissions,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'isSuperAdmin': isSuperAdmin,
    };
  }

  // Copy with method for immutable updates
  Admin copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? managedHotels,
    List<String>? permissions,
    DateTime? createdAt,
    bool? isSuperAdmin,
  }) {
    return Admin(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      managedHotels: managedHotels ?? this.managedHotels,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
    );
  }
}