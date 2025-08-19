class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String address;
  final Map<String, dynamic> preferences;
  final List<String> bookingHistory;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phone = '',
    this.address = '',
    this.preferences = const {},
    this.bookingHistory = const [],
    this.role = 'user',
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'],
    email: map['email'],
    name: map['name'],
    phone: map['phone'] ?? '',
    address: map['address'] ?? '',
    preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
    bookingHistory: List<String>.from(map['bookingHistory'] ?? []),
    role: map['role'] ?? 'user',
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'name': name,
    'phone': phone,
    'address': address,
    'preferences': preferences,
    'bookingHistory': bookingHistory,
    'role': role,
  };
}