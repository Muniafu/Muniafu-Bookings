import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String id;
  final String name;
  final String email;
  final List<String> managedHotels;
  final List<String> permissions;
  final DateTime? createdAt;
  final bool isSuperAdmin;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    this.managedHotels = const [],
    this.permissions = const [],
    this.createdAt,
    this.isSuperAdmin = false,
  });

  bool managesHotel(String hotelId) => 
      isSuperAdmin || managedHotels.contains(hotelId);

  bool hasPermission(String permission) => 
      isSuperAdmin || permissions.contains(permission);

  factory Admin.fromJson(Map<String, dynamic> json) => _parseAdminData(json);

  factory Admin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return _parseAdminData(data).copyWith(id: doc.id);
  }

  Map<String, dynamic> toJson() => _toDataMap();

  Map<String, dynamic> toFirestore() => _toDataMap()
    ..['createdAt'] = createdAt != null 
        ? Timestamp.fromDate(createdAt!) 
        : FieldValue.serverTimestamp();

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

  // Centralized data parser (DRY)
  static Admin _parseAdminData(Map<String, dynamic> data) {
    return Admin(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      managedHotels: List<String>.from(data['managedHotels'] ?? []),
      permissions: List<String>.from(data['permissions'] ?? []),
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : data['createdAt'] != null 
            ? DateTime.parse(data['createdAt'])
            : null,
      isSuperAdmin: data['isSuperAdmin'] ?? false,
    );
  }

  // Centralized data mapper (DRY)
  Map<String, dynamic> _toDataMap() {
    return {
      'name': name,
      'email': email,
      'managedHotels': managedHotels,
      'permissions': permissions,
      'isSuperAdmin': isSuperAdmin,
      if (createdAt != null) 'createdAt': createdAt!,
    };
  }
}

class AdminAction {
  final String id;
  final String title;
  final String description;

  AdminAction({
    required this.id,
    required this.title,
    required this.description,
  });

  // Unified JSON parser
  factory AdminAction.fromJson(Map<String, dynamic> json) {
    return AdminAction(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  // Unified Firestore parser
  factory AdminAction.fromFirestore(DocumentSnapshot doc) {
    return AdminAction(
      id: doc.id,
      title: doc.get('title') ?? '',
      description: doc.get('description') ?? '',
    );
  }

  // Centralized toMap method (DRY)
  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
  };

  // Reusable conversion methods
  Map<String, dynamic> toJson() => toMap();
  Map<String, dynamic> toFirestore() => toMap();

  AdminAction copyWith({
    String? id,
    String? title,
    String? description,
  }) {
    return AdminAction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}