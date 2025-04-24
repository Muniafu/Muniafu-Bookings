import 'package:cloud_firestore/cloud_firestore.dart';

class Hotel {
  final String id;
  final String name;
  final String location;
  final String description;
  final List<String> images; // Multiple images instead of single imageUrl
  final List<String> amenities; // New field from HotelModel
  final double? rating; // New useful field
  final String? ownerId; // For admin/firestore permissions

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.images,
    this.amenities = const [], // Default empty list
    this.rating,
    this.ownerId,
  });

  // Get main image (first in list) for backward compatibility
  String get imageUrl => images.isNotEmpty ? images.first : '';

  // Factory constructor for JSON parsing (API responses)
  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? '', // Null safety from Hotel
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      rating: json['rating']?.toDouble(),
      ownerId: json['ownerId'],
    );
  }

  // Factory constructor for Firestore documents
  factory Hotel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Hotel(
      id: doc.id, // Use document ID from Firestore
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      amenities: List<String>.from(data['amenities'] ?? []),
      rating: data['rating']?.toDouble(),
      ownerId: data['ownerId'],
    );
  }

  // Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'images': images,
      if (amenities.isNotEmpty) 'amenities': amenities,
      if (rating != null) 'rating': rating,
      if (ownerId != null) 'ownerId': ownerId,
    };
  }

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'images': images,
      'amenities': amenities,
      if (rating != null) 'rating': rating,
      if (ownerId != null) 'ownerId': ownerId,
    };
  }

  // Helper for copying with modified fields
  Hotel copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    List<String>? images,
    List<String>? amenities,
    double? rating,
    String? ownerId,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      rating: rating ?? this.rating,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}