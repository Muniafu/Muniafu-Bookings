class Hotel {
  String id;
  String name;
  String location;
  String description;
  String imageUrl;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
  });

  factory Hotel.fromMap(Map<String, dynamic> data) {
    return Hotel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}