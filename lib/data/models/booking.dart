import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { confirmed, cancelled, pending, completed }

class Booking {
  final String id;
  final String userId;
  final String hotelId;
  final String hotelName;
  final String roomId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final double totalAmount;
  final BookingStatus status;
  final DateTime? createdAt;
  final List<String>? specialRequests;

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.hotelName,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.totalAmount,
    this.status = BookingStatus.confirmed,
    this.createdAt,
    this.specialRequests,
  });

  // Getters
  int get durationNights => checkOutDate.difference(checkInDate).inDays;
  double get pricePerNight => totalAmount / durationNights;
  
  bool get isActive {
    final now = DateTime.now();
    return status == BookingStatus.confirmed && 
           checkInDate.isBefore(now) && 
           checkOutDate.isAfter(now);
  }

  // Convert to Firestore Map (for saving to Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'roomId': roomId,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'numberOfGuests': numberOfGuests,
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      if (specialRequests != null) 'specialRequests': specialRequests,
    };
  }

  // Create from Firestore Document (for reading from Firestore)
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      hotelId: data['hotelId'] ?? '',
      hotelName: data['hotelName'] ?? '',
      roomId: data['roomId'] ?? '',
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      checkOutDate: (data['checkOutDate'] as Timestamp).toDate(),
      numberOfGuests: (data['numberOfGuests'] as num).toInt(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      status: _parseStatus(data['status']),
      createdAt: data['createdAt']?.toDate(),
      specialRequests: data['specialRequests'] != null 
          ? List<String>.from(data['specialRequests'])
          : null,
    );
  }

  // Convert to JSON (for API responses)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'roomId': roomId,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'totalAmount': totalAmount,
      'status': status.name,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (specialRequests != null) 'specialRequests': specialRequests,
    };
  }

  // Create from JSON (for API requests)
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      hotelId: json['hotelId'] ?? '',
      hotelName: json['hotelName'] ?? '',
      roomId: json['roomId'] ?? json['room_id'] ?? '',
      checkInDate: _parseDateTime(json['checkInDate'] ?? json['check_in']),
      checkOutDate: _parseDateTime(json['checkOutDate'] ?? json['check_out']),
      numberOfGuests: _parseInt(json['numberOfGuests']) ?? 1,
      totalAmount: _parseDouble(json['totalAmount'] ?? json['total_amount']) ?? 0.0,
      status: _parseStatus(json['status']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      specialRequests: json['specialRequests'] != null 
          ? List<String>.from(json['specialRequests'])
          : null,
    );
  }

  // Immutable copy with updates
  Booking copyWith({
    String? id,
    String? userId,
    String? hotelId,
    String? hotelName,
    String? roomId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    double? totalAmount,
    BookingStatus? status,
    DateTime? createdAt,
    List<String>? specialRequests,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hotelId: hotelId ?? this.hotelId,
      hotelName: hotelName ?? this.hotelName,
      roomId: roomId ?? this.roomId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      specialRequests: specialRequests ?? this.specialRequests,
    );
  }

  // Helper methods
  static BookingStatus _parseStatus(dynamic status) {
    if (status == null) return BookingStatus.confirmed;
    if (status is BookingStatus) return status;
    
    final strStatus = status.toString().toLowerCase();
    switch (strStatus) {
      case 'confirmed': return BookingStatus.confirmed;
      case 'cancelled': return BookingStatus.cancelled;
      case 'pending': return BookingStatus.pending;
      case 'completed': return BookingStatus.completed;
      case 'active': return BookingStatus.confirmed;
      default: return BookingStatus.confirmed;
    }
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date is DateTime) return date;
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}