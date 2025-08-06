import 'package:cloud_firestore/cloud_firestore.dart';

class Hotel {
  final String id;
  final String name;
  final String location;
  final String description;
  final List<String> images;
  final List<String> amenities;
  final double rating;
  final double pricePerNight;
  final String? ownerId;
  final int reviewCount;
  final double latitude;
  final double longitude;
  final int stars;
  final bool isFeatured;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.images,
    required this.amenities,
    required this.rating,
    required this.pricePerNight,
    this.ownerId,
    this.reviewCount = 0,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.stars = 3,
    this.isFeatured = false,
  });

  // Get main image (first in list) for backward compatibility
  String get imageUrl => images.isNotEmpty ? images.first : '';

  // Get average rating formatted
  String get formattedRating => rating.toStringAsFixed(1);

  // Get price formatted
  String get formattedPrice => '\$${pricePerNight.toStringAsFixed(2)}/night';

  // Get star rating
  String get starRating => '${stars} ${stars == 1 ? 'Star' : 'Stars'}';

  // Factory constructor for JSON parsing (API responses)
  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      pricePerNight: (json['price_per_night'] as num?)?.toDouble() ?? 0.0,
      ownerId: json['ownerId'],
      reviewCount: json['review_count'] as int? ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      stars: json['stars'] as int? ?? 3,
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }

  // Factory constructor for Firestore documents
  factory Hotel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Hotel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      amenities: List<String>.from(data['amenities'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      pricePerNight: (data['price_per_night'] as num?)?.toDouble() ?? 0.0,
      ownerId: data['ownerId'],
      reviewCount: data['review_count'] as int? ?? 0,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      stars: data['stars'] as int? ?? 3,
      isFeatured: data['is_featured'] as bool? ?? false,
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
      'amenities': amenities,
      'rating': rating,
      'price_per_night': pricePerNight,
      if (ownerId != null) 'ownerId': ownerId,
      'review_count': reviewCount,
      'latitude': latitude,
      'longitude': longitude,
      'stars': stars,
      'is_featured': isFeatured,
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
      'rating': rating,
      'price_per_night': pricePerNight,
      if (ownerId != null) 'ownerId': ownerId,
      'review_count': reviewCount,
      'latitude': latitude,
      'longitude': longitude,
      'stars': stars,
      'is_featured': isFeatured,
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
    double? pricePerNight,
    String? ownerId,
    int? reviewCount,
    double? latitude,
    double? longitude,
    int? stars,
    bool? isFeatured,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      rating: rating ?? this.rating,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      ownerId: ownerId ?? this.ownerId,
      reviewCount: reviewCount ?? this.reviewCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      stars: stars ?? this.stars,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  // Equality check
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Hotel &&
        other.id == id &&
        other.name == name &&
        other.location == location &&
        other.description == description &&
        other.images == images &&
        other.amenities == amenities &&
        other.rating == rating &&
        other.pricePerNight == pricePerNight &&
        other.ownerId == ownerId &&
        other.reviewCount == reviewCount &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.stars == stars &&
        other.isFeatured == isFeatured;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        location.hashCode ^
        description.hashCode ^
        images.hashCode ^
        amenities.hashCode ^
        rating.hashCode ^
        pricePerNight.hashCode ^
        ownerId.hashCode ^
        reviewCount.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        stars.hashCode ^
        isFeatured.hashCode;
  }

  @override
  String toString() {
    return 'Hotel(id: $id, name: $name, location: $location, '
        'description: $description, images: $images, amenities: $amenities, '
        'rating: $rating, pricePerNight: $pricePerNight, ownerId: $ownerId, '
        'reviewCount: $reviewCount, latitude: $latitude, longitude: $longitude, '
        'stars: $stars, isFeatured: $isFeatured)';
  }
}