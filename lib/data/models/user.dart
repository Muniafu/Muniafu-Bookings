import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
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
  String? fullName;

  User({
    required this.uid,
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
    this.fullName,
  }) {
    // Initialize fullName from name if not provided
    fullName ??= name;
  }

  // Getter to check admin status
  bool get isAdmin => role == 'admin';

  // Factory constructor for Firestore documents
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User.fromJson({...data, 'id': doc.id});
  }

  // JSON parsing with backward compatibility
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['id'] ?? json['uid'] ?? '',
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
      fullName: json['fullName'] ?? json['name'],
    );
  }

  // Convert to JSON for API/storage
  Map<String, dynamic> toJson() {
    return {
      'id': uid,
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
      if (fullName != null) 'fullName': fullName,
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
      if (fullName != null) 'fullName': fullName,
    };
  }

  // Simple map conversion (from AppUser)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'fullName': fullName,
      'phone': phone,
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
    String? fullName,
  }) {
    return User(
      uid: id ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      darkMode: darkMode ?? this.darkMode,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(), // Always update timestamp
      birthDate: birthDate ?? this.birthDate,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      fullName: fullName ?? this.fullName,
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
        other.uid == uid &&
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
        other.bio == bio &&
        other.fullName == fullName;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
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
        bio.hashCode ^
        fullName.hashCode;
  }

  // Debugging representation
  @override
  String toString() {
    return 'User('
        'id: $uid, '
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
        'bio: $bio, '
        'fullName: $fullName'
        ')';
  }
}