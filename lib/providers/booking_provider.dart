import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/booking.dart';
import '../data/services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService;
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  BookingProvider(this._bookingService);

  // Getters
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered bookings
  List<Booking> get activeBookings => _bookings.where((b) => 
      b.status == BookingStatus.confirmed && 
      b.checkOutDate.isAfter(DateTime.now())).toList();

  List<Booking> get pastBookings => _bookings.where((b) => 
      b.checkOutDate.isBefore(DateTime.now())).toList();

  List<Booking> get myBookings => _bookings; // Alias for compatibility

  /// Fetches bookings manually (initial load/fallback)
  Future<void> fetchBookings({String? userId}) async {
    try {
      _setLoading(true);
      _error = null;
      
      final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      _bookings = await _bookingService.getBookingsForUser(uid);
    } catch (e) {
      _error = 'Failed to fetch bookings: ${e.toString()}';
      debugPrint(_error!);
    } finally {
      _setLoading(false);
    }
  }

  /// Sets up realtime listener for user's bookings
  void listenToUserBookings(String userId) {
    _bookingService.streamUserBookings(userId).listen(
      (bookings) {
        _bookings = bookings;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to stream bookings: ${e.toString()}';
        notifyListeners();
      },
    );
  }

  /// Sets up realtime listener for all bookings (admin only)
  void listenToAllBookings() {
    _bookingService.streamAllBookings().listen(
      (bookings) {
        _bookings = bookings;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to stream all bookings: ${e.toString()}';
        notifyListeners();
      },
    );
  }

  /// Cancels a booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      _setLoading(true);
      await _bookingService.cancelBooking(bookingId);
      
      // Update local state
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.cancelled,
        );
      }
    } catch (e) {
      _error = 'Failed to cancel booking: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Creates a mock booking (for testing/demo)
  Future<String> createMockBooking(String roomId) async {
    try {
      _setLoading(true);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final bookingId = await _bookingService.createMockBooking(
        userId: user.uid,
        roomId: roomId,
      );

      _notifyAdmin(bookingId);
      return bookingId;
    } finally {
      _setLoading(false);
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _notifyAdmin(String bookingId) {
    debugPrint('[Admin Alert] New booking created: $bookingId');
  }
}