import 'package:flutter/material.dart';
import '../data/services/booking_service.dart';
import '../data/models/booking.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService;
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  BookingProvider(this._bookingService);

  // Getters
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  // Fetch bookings for a user
  Future<void> fetchBookings(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _bookings = await _bookingService.fetchBookingsByUser(userId);
    } catch (e) {
      _error = 'Failed to fetch bookings: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new booking
  Future<void> addBooking(Booking booking) async {
    try {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      final newBooking = await _bookingService.createBooking(booking as Map<String, dynamic>);
      _bookings.add(newBooking as Booking);
      _successMessage = 'Booking successful!';
    } catch (e) {
      _error = 'Failed to create booking: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      await _bookingService.cancelBooking(bookingId);
      _bookings.removeWhere((booking) => booking.id == bookingId);
      _successMessage = 'Booking cancelled successfully';
    } catch (e) {
      _error = 'Failed to cancel booking: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get upcoming bookings
  List<Booking> getUpcomingBookings() {
    final now = DateTime.now();
    return _bookings.where((booking) => 
      booking.checkInDate.isAfter(now)
    ).toList();
  }

  // Clear messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}