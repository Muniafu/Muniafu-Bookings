class HotelModel {
  final String id;
  final String name;
  final String address;
  final Map<String, double> coordinates;
  final String description;
  final List<String> amenities;
  final List<String> images;
  final double rating;

  // merchandising / availability / pricing fields
  final bool isPopular;
  final bool isNew;
  final double avgPrice;
  final double basePrice;
  final double taxRate;
  final List<String> seoTags;

  // added for UI badges & availability
  final int availableRooms;
  final List<String> tags;

  HotelModel({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinates,
    required this.description,
    required this.amenities,
    required this.images,
    required this.rating,
    this.isPopular = false,
    this.isNew = false,
    this.avgPrice = 0.0,
    this.basePrice = 0.0,
    this.taxRate = 0.0,
    this.seoTags = const [],
    this.availableRooms = 0,
    this.tags = const [], String? coverImage,
  });

  factory HotelModel.fromMap(Map<String, dynamic>? map, {String? id}) {
    map ??= {};
    // coords safe conversion
    final coordsRaw = (map['coordinates'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    final Map<String, double> coords = {};
    coordsRaw.forEach((k, v) {
      if (v is num) {
        coords[k] = v.toDouble();
      } else {
        coords[k] = double.tryParse(v.toString()) ?? 0.0;
      }
    });

    List<String> parseList(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      return v.toString().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }

    return HotelModel(
      id: id ?? (map['id']?.toString() ?? ''),
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      coordinates: coords,
      description: map['description']?.toString() ?? '',
      amenities: parseList(map['amenities']),
      images: parseList(map['images']),
      rating: (map['rating'] ?? 0).toDouble(),
      isPopular: map['isPopular'] ?? false,
      isNew: map['isNew'] ?? false,
      avgPrice: (map['avgPrice'] ?? 0).toDouble(),
      basePrice: (map['basePrice'] ?? 0).toDouble(),
      taxRate: (map['taxRate'] ?? 0).toDouble(),
      seoTags: parseList(map['seoTags']),
      availableRooms: (map['availableRooms'] ?? 0) is int ? (map['availableRooms'] as int) : ((map['availableRooms'] ?? 0).toInt ? (map['availableRooms'] as int) : int.tryParse((map['availableRooms'] ?? '0').toString()) ?? 0),
      tags: parseList(map['tags']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'coordinates': coordinates,
        'description': description,
        'amenities': amenities,
        'images': images,
        'rating': rating,
        'isPopular': isPopular,
        'isNew': isNew,
        'avgPrice': avgPrice,
        'basePrice': basePrice,
        'taxRate': taxRate,
        'seoTags': seoTags,
        'availableRooms': availableRooms,
        'tags': tags,
      };
}