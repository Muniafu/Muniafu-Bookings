import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  String name;
  final String email;
  String? photoUrl;
  bool emailVerified;
  bool darkMode;
  final String role;
  final DateTime createdAt;
  DateTime updatedAt;
  String? birthDate;
  String? location;
  String? phone;
  String? bio;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.emailVerified = false,
    this.darkMode = false,
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

  // JSON parsing with backward compatibility
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? json['displayName'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'] ?? json['photo_url'] ?? json['avatarUrl'],
      emailVerified: json['emailVerified'] ?? json['email_verified'] ?? false,
      darkMode: json['darkMode'] ?? json['dark_mode'] ?? false,
      role: json['role'] ?? 'user',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? DateTime.now()),
      birthDate: json['birthDate'] ?? json['birth_date'],
      location: json['location'] ?? json['address'],
      phone: json['phone'] ?? json['phoneNumber'],
      bio: json['bio'] ?? json['about'],
    );
  }

  // Firestore document parsing
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User.fromJson({...data, 'id': doc.id});
  }

  // Convert to JSON for API/storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'darkMode': darkMode,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (birthDate != null) 'birthDate': birthDate,
      if (location != null) 'location': location,
      if (phone != null) 'phone': phone,
      if (bio != null) 'bio': bio,
    };
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'darkMode': darkMode,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (birthDate != null) 'birthDate': birthDate,
      if (location != null) 'location': location,
      if (phone != null) 'phone': phone,
      if (bio != null) 'bio': bio,
    };
  }

  // Immutable updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    bool? emailVerified,
    bool? darkMode,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? birthDate,
    String? location,
    String? phone,
    String? bio,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      darkMode: darkMode ?? this.darkMode,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      birthDate: birthDate ?? this.birthDate,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
    );
  }

  // Helper methods
  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  // Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.photoUrl == photoUrl &&
        other.emailVerified == emailVerified &&
        other.darkMode == darkMode &&
        other.role == role &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.birthDate == birthDate &&
        other.location == location &&
        other.phone == phone &&
        other.bio == bio;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        photoUrl.hashCode ^
        emailVerified.hashCode ^
        darkMode.hashCode ^
        role.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        birthDate.hashCode ^
        location.hashCode ^
        phone.hashCode ^
        bio.hashCode;
  }

  // Debugging representation
  @override
  String toString() {
    return 'User('
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'photoUrl: $photoUrl, '
        'emailVerified: $emailVerified, '
        'darkMode: $darkMode, '
        'role: $role, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'birthDate: $birthDate, '
        'location: $location, '
        'phone: $phone, '
        'bio: $bio'
        ')';
  }
}