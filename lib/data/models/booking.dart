import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String hotelId;
  final String roomId; // Added from BookingModel
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final double totalPrice; // Added from BookingModel
  final String status; // New field: 'confirmed', 'cancelled', 'pending'
  final DateTime? createdAt; // New field for record-keeping
  final List<String>? specialRequests; // New field for guest requests

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.totalPrice,
    this.status = 'confirmed',
    this.createdAt,
    this.specialRequests,
  });

  // Calculate duration in nights (from BookingModel)
  int get durationNights => checkOutDate.difference(checkInDate).inDays;

  // Calculate price per night (helper method)
  double get pricePerNight => totalPrice / durationNights;

  // Check if booking is active (new helper method)
  bool get isActive {
    final now = DateTime.now();
    return status == 'confirmed' && 
           checkInDate.isBefore(now) && 
           checkOutDate.isAfter(now);
  }

  // Factory constructor for JSON parsing (API responses)
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      hotelId: json['hotelId'] ?? '',
      roomId: json['roomId'] ?? '',
      checkInDate: DateTime.parse(json['checkInDate'] ?? DateTime.now().toString()),
      checkOutDate: DateTime.parse(json['checkOutDate'] ?? DateTime.now().toString()),
      numberOfGuests: (json['numberOfGuests'] as num?)?.toInt() ?? 1,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'confirmed',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      specialRequests: json['specialRequests'] != null 
          ? List<String>.from(json['specialRequests'])
          : null,
    );
  }

  // Factory constructor for Firestore documents
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id, // Use document ID from Firestore
      userId: data['userId'] ?? '',
      hotelId: data['hotelId'] ?? '',
      roomId: data['roomId'] ?? '',
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      checkOutDate: (data['checkOutDate'] as Timestamp).toDate(),
      numberOfGuests: (data['numberOfGuests'] as num).toInt(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      status: data['status'] ?? 'confirmed',
      createdAt: data['createdAt']?.toDate(),
      specialRequests: data['specialRequests'] != null 
          ? List<String>.from(data['specialRequests'])
          : null,
    );
  }

  // Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'hotelId': hotelId,
      'roomId': roomId,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'totalPrice': totalPrice,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (specialRequests != null) 'specialRequests': specialRequests,
    };
  }

  // Convert to Map (for Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'hotelId': hotelId,
      'roomId': roomId,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'numberOfGuests': numberOfGuests,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      if (specialRequests != null) 'specialRequests': specialRequests,
    };
  }

  // Copy with method for immutable updates
  Booking copyWith({
    String? id,
    String? userId,
    String? hotelId,
    String? roomId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    List<String>? specialRequests,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hotelId: hotelId ?? this.hotelId,
      roomId: roomId ?? this.roomId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      specialRequests: specialRequests ?? this.specialRequests,
    );
  }
}