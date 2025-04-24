import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String hotelId;
  final String type; // e.g., 'Standard', 'Deluxe', 'Suite'
  final String name; // Added field for room names
  final double pricePerNight;
  final int capacity;
  final List<String> images;
  final List<String> amenities; // Added field for room amenities
  final bool isAvailable;
  final double? discount; // Nullable discount percentage
  final String? description; // Added detailed description

  Room({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.pricePerNight,
    required this.capacity,
    required this.images,
    required this.isAvailable,
    this.name = '',
    this.amenities = const [],
    this.discount,
    this.description,
  });

  // Calculate total price with optional discount
  double calculateTotalPrice(int nights) {
    final basePrice = pricePerNight * nights;
    return discount != null 
        ? basePrice * (1 - discount!)
        : basePrice;
  }

  // Get discounted price for single night
  double get discountedPrice => discount != null
      ? pricePerNight * (1 - discount!)
      : pricePerNight;

  // Factory constructor for JSON parsing
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? '',
      hotelId: json['hotelId'] ?? '',
      type: json['type'] ?? 'Standard',
      name: json['name'] ?? '',
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      capacity: (json['capacity'] as num?)?.toInt() ?? 1,
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      discount: (json['discount'] as num?)?.toDouble(),
      description: json['description'],
    );
  }

  // Factory constructor for Firestore
  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room.fromJson({...data, 'id': doc.id});
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotelId': hotelId,
      'type': type,
      if (name.isNotEmpty) 'name': name,
      'pricePerNight': pricePerNight,
      'capacity': capacity,
      'images': images,
      if (amenities.isNotEmpty) 'amenities': amenities,
      'isAvailable': isAvailable,
      if (discount != null) 'discount': discount,
      if (description != null) 'description': description,
    };
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'hotelId': hotelId,
      'type': type,
      if (name.isNotEmpty) 'name': name,
      'pricePerNight': pricePerNight,
      'capacity': capacity,
      'images': images,
      if (amenities.isNotEmpty) 'amenities': amenities,
      'isAvailable': isAvailable,
      if (discount != null) 'discount': discount,
      if (description != null) 'description': description,
    };
  }

  // Copy with method for immutable updates
  Room copyWith({
    String? id,
    String? hotelId,
    String? type,
    String? name,
    double? pricePerNight,
    int? capacity,
    List<String>? images,
    List<String>? amenities,
    bool? isAvailable,
    double? discount,
    String? description,
  }) {
    return Room(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      type: type ?? this.type,
      name: name ?? this.name,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      capacity: capacity ?? this.capacity,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      isAvailable: isAvailable ?? this.isAvailable,
      discount: discount ?? this.discount,
      description: description ?? this.description,
    );
  }
}