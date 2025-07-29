import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/booking.dart';
import 'package:uuid/uuid.dart';

class BookingService {
  final _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<String> createMockBooking({
    required String userId,
    required String roomId,
  }) async {
    final bookingId = _uuid.v4();

    await _firestore.collection('bookings').doc(bookingId).set({
      'id': bookingId,
      'userId': userId,
      'roomId': roomId,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
      'mockPayment': true,
    });

    return bookingId;
  }
}