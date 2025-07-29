import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../data/models/booking.dart';
import '../data/services/booking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  final List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  BookingProvider(BookingService bookingService);

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Booking> get activeBookings => _bookings.where((b) => b.checkInDate.isAfter(DateTime.now())).toList();

  List<Booking> get pastBookings => _bookings.where((b) => b.checkOutDate.isBefore(DateTime.now())).toList();

  Future<void> fetchBookings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance.collection('bookings').where('userId', isEqualTo: userId).orderBy('CreatedAt', descending: true).get();

      _bookings.clear();
      for (final doc in snapshot.docs) {
        _bookings.add(Booking.fromFirestore(doc));
      }
    } catch (e) {
      _error = 'Failed to fetch bookings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({'status': 'cancelled'});

      _bookings.removeWhere((b) => b.id == bookingId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> mockCreateBooking(String roomId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');

    final bookingId = await _bookingService.createMockBooking(
      userId: user.uid,
      roomId: roomId,
    );

    // Notify admin (in-app mock for now)
    _notifyAdmin(bookingId);

    return bookingId;
  }

  void _notifyAdmin(String bookingId) {
    // You can also trigger Firestore entry or FCM call here
    debugPrint('[Admin Alert] new booking created: $bookingId');
  }
}