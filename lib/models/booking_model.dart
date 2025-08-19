class BookingModel {
  final String id;
  final String userId;
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalPrice;
  final String status;
  final String paymentId;

  BookingModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
    required this.paymentId,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) => BookingModel(
    id: map['id'],
    userId: map['userId'],
    roomId: map['roomId'],
    checkIn: DateTime.parse(map['checkIn']),
    checkOut: DateTime.parse(map['checkOut']),
    guests: map['guests'],
    totalPrice: (map['totalPrice'] ?? 0).toDouble(),
    status: map['status'],
    paymentId: map['paymentId'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'roomId': roomId,
    'checkIn': checkIn.toIso8601String(),
    'checkOut': checkOut.toIso8601String(),
    'guests': guests,
    'totalPrice': totalPrice,
    'status': status,
    'paymentId': paymentId,
  };
}