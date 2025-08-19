class RoomModel {
  final String id;
  final String hotelId;
  final String name;
  final String type;
  final String description;
  final double pricePerNight;
  final int capacity;
  final List<String> features;
  final List<String> images;
  final List<String> amenities;
  final bool isAvailable;
  final double size;

  RoomModel({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.type,
    required this.description,
    required this.pricePerNight,
    required this.capacity,
    required this.features,
    required this.images,
    required this.amenities,
    this.isAvailable = true,
    this.size = 0.0,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map) => RoomModel(
    id: map['id'],
    hotelId: map['hotelId'],
    name: map['name'] ?? '',
    type: map['type'] ?? 'Standard',
    description: map['description'] ?? '',
    pricePerNight: (map['pricePerNight'] ?? 0).toDouble(),
    capacity: map['capacity'] ?? 1,
    features: List<String>.from(map['features'] ?? []),
    images: List<String>.from(map['images'] ?? []),
    amenities: List<String>.from(map['amenities'] ?? []),
    isAvailable: map['isAvailable'] ?? true,
    size: (map['size'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'hotelId': hotelId,
    'name': name,
    'type': type,
    'description': description,
    'pricePerNight': pricePerNight,
    'capacity': capacity,
    'features': features,
    'images': images,
    'amenities': amenities,
    'isAvailable': isAvailable,
    'size': size,
  };
}