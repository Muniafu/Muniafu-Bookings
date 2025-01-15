class Room {
  String id;
  String hotelId;
  String type;
  double price;
  int capacity;

  Room({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.price,
    required this.capacity,
  });

  factory Room.fromMap(Map<String, dynamic> data) {
    return Room(
      id: data['id'] ?? '',
      hotelId: data['hotelId'] ?? '',
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      capacity: data['capacity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hotelId': hotelId,
      'type': type,
      'price': price,
      'capacity': capacity,
    };
  }
}