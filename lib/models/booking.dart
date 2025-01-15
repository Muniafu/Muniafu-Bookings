class Booking {
  String id;
  String userId;
  String hotelId;
  DateTime checkInDate;
  DateTime checkOutdate;
  int numberOfGuests;

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.checkInDate,
    required this.checkOutdate,
    required this.numberOfGuests,
  });

  factory Booking.fromMap(Map<String, dynamic> data) {
    return Booking(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      hotelId: data['hotelId'] ?? '',
      checkInDate: DateTime.parse(data['checkInDate'] ?? DateTime.now().toString()),
      checkOutdate: DateTime.parse(data['checkOutDate'] ?? DateTime.now().toString()),
      numberOfGuests: data['numberOf Guests'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userid': userId,
      'hotelId': hotelId,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutdate': checkOutdate.toIso8601String(),
      'numberOfGuests': numberOfGuests,
    };
  }
}