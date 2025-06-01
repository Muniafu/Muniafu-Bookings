import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String hotelId;
  final String type;
  final String name;
  final double pricePerNight;
  final int capacity;
  final bool isAvailable;
  final List<String> images;
  final List<String> amenities;
  final double? discount;
  final String? description;

  Room({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.pricePerNight,
    required this.capacity,
    required this.isAvailable,
    required this.images,
    this.name = '',
    this.amenities = const [],
    this.discount,
    this.description,
  });

  // Calculate total price with discount
  double calculateTotalPrice(int nights) => 
      discount != null
        ? (pricePerNight * (1 - discount!)) * nights
        : pricePerNight * nights;

  // Get discounted price for single night
  double get discountedPrice => 
      discount != null
        ? pricePerNight * (1 - discount!)
        : pricePerNight;

  // JSON parsing with backward compatibility
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id']?.toString() ?? '',
      hotelId: json['hotelId']?.toString() ?? json['hotel_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Standard',
      name: json['name']?.toString() ?? '',
      pricePerNight: _parseDouble(json['pricePerNight'] ?? json['price']),
      capacity: _parseInt(json['capacity']) ?? 1,
      isAvailable: json['isAvailable'] ?? json['available'] ?? true,
      images: _parseStringList(json['images']),
      amenities: _parseStringList(json['amenities']),
      discount: _parseDouble(json['discount']),
      description: json['description']?.toString(),
    );
  }

  // Firestore integration
  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room.fromJson({...data, 'id': doc.id});
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'hotelId': hotelId,
    'type': type,
    if (name.isNotEmpty) 'name': name,
    'pricePerNight': pricePerNight,
    'capacity': capacity,
    'isAvailable': isAvailable,
    'images': images,
    if (amenities.isNotEmpty) 'amenities': amenities,
    if (discount != null) 'discount': discount,
    if (description != null) 'description': description,
  };

  // Firestore serialization
  Map<String, dynamic> toFirestore() => {
    'hotelId': hotelId,
    'type': type,
    if (name.isNotEmpty) 'name': name,
    'pricePerNight': pricePerNight,
    'capacity': capacity,
    'isAvailable': isAvailable,
    'images': images,
    if (amenities.isNotEmpty) 'amenities': amenities,
    if (discount != null) 'discount': discount,
    if (description != null) 'description': description,
  };

  // Immutable updates
  Room copyWith({
    String? id,
    String? hotelId,
    String? type,
    String? name,
    double? pricePerNight,
    int? capacity,
    bool? isAvailable,
    List<String>? images,
    List<String>? amenities,
    double? discount,
    String? description,
  }) => Room(
    id: id ?? this.id,
    hotelId: hotelId ?? this.hotelId,
    type: type ?? this.type,
    name: name ?? this.name,
    pricePerNight: pricePerNight ?? this.pricePerNight,
    capacity: capacity ?? this.capacity,
    isAvailable: isAvailable ?? this.isAvailable,
    images: images ?? this.images,
    amenities: amenities ?? this.amenities,
    discount: discount ?? this.discount,
    description: description ?? this.description,
  );

  // Helper methods (private)
  static double _parseDouble(dynamic value) => 
      (value is num?) ? value?.toDouble() ?? 0.0 : 0.0;

  static int? _parseInt(dynamic value) => 
      (value is num?) ? value?.toInt() : null;

  static List<String> _parseStringList(dynamic data) => 
      (data is List) 
        ? List<String>.from(data.map((e) => e.toString())) 
        : [];
}